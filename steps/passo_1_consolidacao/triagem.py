import json
import logging
from copy import deepcopy
from dataclasses import asdict
from typing import List, Optional

from core.models import Documento, ResultadoConsolidacao, ValidacaoResultado
from core.status import (
    ACAO_ENVIAR_PASSO_2,
    ACAO_FECHAR_MANUAL,
    ACAO_RETORNAR_OFICINA,
    CONSOLIDACAO_APROVADA,
    CONSOLIDACAO_ERRO_TECNICO,
    CONSOLIDACAO_PENDENTE_BATIMENTO,
    CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
    CONSOLIDACAO_REPROVADA_FALTA_ANEXO,
    CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO,
    CONSOLIDACAO_REPROVADA_TERMO_INVALIDO,
    CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
    STATUS_APROVADO,
    STATUS_ERRO,
    STATUS_PENDENTE,
    STATUS_REPROVADO,
)
from integrations.conference.client import ApiConferenceClient
from services.ia.document_reader import build_document_reader
from services.validacoes.classificador import classificar_consolidacao
from services.validacoes.cnpj import validar_cnpj
from services.validacoes.anexos import validar_anexos
from services.validacoes.dados_conference import validar_dados_conference_basicos
from services.validacoes.orcamento import validar_orcamento
from services.validacoes.termo_quitacao import validar_termo_quitacao


logger = logging.getLogger(__name__)


ALLIANZ_CNPJS = {
    "61573796000166",
    "61573796003343",
    "61573796004315",
    "61573796012172",
}

OCORRENCIAS_DESATIVADAS = {"C22", "C27"}
MENSAGEM_VALOR_FRANQUIA_DIVERGENTE = (
    "Valor informado na Fraquia está incorreta. "
    "Favor corrigir conforme orçamento aprovado no site da seguradora."
)


class Passo1TriagemConference:
    def __init__(
        self,
        conference_client: ApiConferenceClient,
        repository=None,
        cache=None,
        document_reader=None,
        cancel_checker=None,
        progress_callback=None,
    ):
        self.conference_client = conference_client
        self.repository = repository
        self.cache = cache
        self.document_reader = document_reader or build_document_reader()
        self.cancel_checker = cancel_checker
        self.progress_callback = progress_callback
        self._progress_context = {}

    def listar(
        self,
        tipo_data: int = 1,
        status: int = 5,
        empresa: Optional[int] = None,
        reler_orcamento: bool = False,
        reler_documentos: bool = False,
    ) -> List[ResultadoConsolidacao]:
        resultados = []
        novos_resultados = []
        registros = list(self._listar_snapshots_consolidacoes(status=status, empresa=empresa))
        print(
            f"PASSO1 listar consolidacoes total={len(registros)} status={status} empresa={empresa} "
            f"reler_orcamento={reler_orcamento} reler_documentos={reler_documentos}",
            flush=True,
        )
        logger.info(
            "PASSO1 listar consolidacoes total=%s status=%s empresa=%s reler_orcamento=%s reler_documentos=%s",
            len(registros),
            status,
            empresa,
            reler_orcamento,
            reler_documentos,
        )
        self._notificar_progresso(
            etapa="LISTANDO_OS",
            total=len(registros),
            processadas=0,
            pendentes=len(registros),
            status_conference=status,
            empresa=empresa,
        )
        for indice, registro in enumerate(registros, start=1):
            self._verificar_cancelamento()
            codigo = _codigo_registro(registro)
            self._progress_context = {
                "total": len(registros),
                "indice": indice,
                "processadas": indice - 1,
                "pendentes": max(len(registros) - indice + 1, 0),
                "os": codigo,
            }
            if not codigo:
                self._notificar_progresso(etapa="REGISTRO_SEM_CODIGO")
                resultado = self._erro_sem_codigo(registro)
                self._persistir(resultado)
                resultados.append(resultado)
                continue

            self.conference_client.cache_sinistro(registro)

            aprovado = self._buscar_aprovado(codigo)
            if aprovado:
                self._notificar_progresso(
                    etapa="IGNORADA_JA_APROVADA",
                    processadas=indice,
                    pendentes=max(len(registros) - indice, 0),
                    status_resultado=aprovado.status_consolidacao,
                )
                print(f"PASSO1 OS {codigo} ignorada: ja aprovada ({indice}/{len(registros)})", flush=True)
                logger.info("PASSO1 OS %s ignorada: ja aprovada (%s/%s)", codigo, indice, len(registros))
                resultados.append(aprovado)
                continue

            self._notificar_progresso(etapa="INICIANDO_OS")
            print(f"PASSO1 OS {codigo} iniciando ({indice}/{len(registros)})", flush=True)
            logger.info("PASSO1 OS %s iniciando (%s/%s)", codigo, indice, len(registros))
            resultado = self.executar_codigo(
                codigo,
                persistir=True,
                reler_orcamento=reler_orcamento,
                reler_documentos=reler_documentos,
            )
            print(
                f"PASSO1 OS {codigo} finalizada status={resultado.status_consolidacao} ({indice}/{len(registros)})",
                flush=True,
            )
            logger.info(
                "PASSO1 OS %s finalizada status=%s (%s/%s)",
                codigo,
                resultado.status_consolidacao,
                indice,
                len(registros),
            )
            self._verificar_cancelamento()
            self._notificar_progresso(
                etapa="OS_FINALIZADA",
                processadas=indice,
                pendentes=max(len(registros) - indice, 0),
                status_resultado=resultado.status_consolidacao,
                acao_sugerida=resultado.acao_sugerida,
            )
            resultados.append(resultado)
            novos_resultados.append(resultado)

        print(f"PASSO1 listar concluido novos_resultados={len(novos_resultados)}", flush=True)
        logger.info("PASSO1 listar concluido novos_resultados=%s", len(novos_resultados))
        self._notificar_progresso(
            etapa="RESULTADOS_CONCLUIDOS",
            processadas=len(registros),
            pendentes=0,
            novos_resultados=len(novos_resultados),
        )
        return resultados

    def executar_codigo(
        self,
        codigo: str,
        persistir: bool = True,
        forcar: bool = False,
        reler_orcamento: bool = False,
        reler_documentos: bool = False,
        ignorar_complemento_manual: bool = False,
        forcar_releitura: bool = False,
    ) -> ResultadoConsolidacao:
        try:
            aprovado = self._buscar_aprovado(codigo)
            if aprovado and not forcar:
                return aprovado

            self._notificar_progresso(etapa="BUSCANDO_DADOS_CONFERENCE")
            print(f"PASSO1 OS {codigo} cache/busca Conference iniciando", flush=True)
            logger.info("PASSO1 OS %s cache/busca Conference iniciando", codigo)
            self._cache_snapshot_conference(codigo)
            dados = self.conference_client.buscar_dados_os(codigo)

            if _dados_indicam_complementar(dados) and not ignorar_complemento_manual:
                self._notificar_progresso(etapa="OS_COMPLEMENTAR_MANUAL")
                print(f"PASSO1 OS {codigo} complementar: marcado manual sem demais validacoes", flush=True)
                logger.info("PASSO1 OS %s complementar: marcado manual sem demais validacoes", codigo)
                resultado = _resultado_complementar(codigo, dados)
                if persistir:
                    self._persistir(resultado)
                return resultado

            anexos_conference = self._buscar_anexos_conference(codigo)
            dados.anexos = anexos_conference
            self._notificar_progresso(etapa="DADOS_CONFERENCE_OK", anexos=len(anexos_conference))
            print(f"PASSO1 OS {codigo} Conference OK anexos={len(anexos_conference)}", flush=True)
            logger.info("PASSO1 OS %s Conference OK anexos=%s", codigo, len(anexos_conference))
            dados_extraidos_anteriores = self._buscar_dados_extraidos(codigo)
            ajustes_manuais_atuais = dados_extraidos_anteriores.get("ajustes_manuais_atuais") or {}
            tem_ajuste_manual = bool(ajustes_manuais_atuais)
            orcamento_lido_nesta_execucao = False
            tentativas_modelos_orcamento = dados_extraidos_anteriores.get("tentativas_modelos_orcamento") or []
            dados_orcamento = (
                dados_extraidos_anteriores.get("orcamento")
                if not forcar_releitura and (tem_ajuste_manual or not (reler_orcamento or reler_documentos))
                else None
            )
            dados_termo = (
                dados_extraidos_anteriores.get("termo_quitacao")
                if not forcar_releitura and (tem_ajuste_manual or not reler_documentos)
                else None
            )
            dados_faturamento = (
                dados_extraidos_anteriores.get("dados_faturamento")
                if not forcar_releitura and (tem_ajuste_manual or not reler_documentos)
                else None
            )
            arquivo_orcamento = (dados_extraidos_anteriores.get("downloads") or {}).get("orcamento_final")
            arquivo_termo = (dados_extraidos_anteriores.get("downloads") or {}).get("termo_quitacao")
            arquivo_dados_faturamento = (
                (dados_extraidos_anteriores.get("downloads") or {}).get("dados_faturamento")
            )

            if not dados_orcamento and (not tem_ajuste_manual or forcar_releitura):
                self._notificar_progresso(etapa="BAIXANDO_ORCAMENTO")
                print(f"PASSO1 OS {codigo} download orcamento iniciando", flush=True)
                logger.info("PASSO1 OS %s download orcamento iniciando", codigo)
                arquivo_orcamento = self.conference_client.download_documento(codigo, "orcamento_final")
                self._notificar_progresso(etapa="ORCAMENTO_BAIXADO", arquivo=bool(arquivo_orcamento))
                print(f"PASSO1 OS {codigo} download orcamento arquivo={bool(arquivo_orcamento)}", flush=True)
                logger.info("PASSO1 OS %s download orcamento arquivo=%s", codigo, bool(arquivo_orcamento))

            if arquivo_orcamento and not dados_orcamento and (not tem_ajuste_manual or forcar_releitura):
                self._notificar_progresso(etapa="LENDO_ORCAMENTO_IA")
                print(f"PASSO1 OS {codigo} leitura IA orcamento iniciando", flush=True)
                logger.info("PASSO1 OS %s leitura IA orcamento iniciando", codigo)
                dados_orcamento = self.document_reader.ler_orcamento(arquivo_orcamento, seguradora=dados.seguradora)
                orcamento_lido_nesta_execucao = True
                self._notificar_progresso(etapa="ORCAMENTO_IA_OK")
                print(f"PASSO1 OS {codigo} leitura IA orcamento OK", flush=True)
                logger.info("PASSO1 OS %s leitura IA orcamento OK", codigo)

            if _eh_allianz(dados) and not dados_faturamento:
                self._notificar_progresso(etapa="BAIXANDO_DADOS_FATURAMENTO")
                print(f"PASSO1 OS {codigo} download dados faturamento Allianz iniciando", flush=True)
                logger.info("PASSO1 OS %s download dados faturamento Allianz iniciando", codigo)
                arquivo_dados_faturamento = self.conference_client.download_documento(
                    codigo,
                    "dados_faturamento",
                )
                self._notificar_progresso(
                    etapa="DADOS_FATURAMENTO_BAIXADO",
                    arquivo=bool(arquivo_dados_faturamento),
                )
                print(
                    f"PASSO1 OS {codigo} download dados faturamento Allianz "
                    f"arquivo={bool(arquivo_dados_faturamento)}",
                    flush=True,
                )
                logger.info(
                    "PASSO1 OS %s download dados faturamento Allianz arquivo=%s",
                    codigo,
                    bool(arquivo_dados_faturamento),
                )

            if (
                _eh_allianz(dados)
                and arquivo_dados_faturamento
                and not dados_faturamento
            ):
                self._notificar_progresso(etapa="LENDO_DADOS_FATURAMENTO_IA")
                print(f"PASSO1 OS {codigo} leitura IA dados faturamento Allianz iniciando", flush=True)
                logger.info("PASSO1 OS %s leitura IA dados faturamento Allianz iniciando", codigo)
                dados_faturamento = self.document_reader.ler_dados_faturamento(
                    arquivo_dados_faturamento
                )
                self._notificar_progresso(etapa="DADOS_FATURAMENTO_IA_OK")
                print(f"PASSO1 OS {codigo} leitura IA dados faturamento Allianz OK", flush=True)
                logger.info("PASSO1 OS %s leitura IA dados faturamento Allianz OK", codigo)

            dados_orcamento = _aplicar_ajustes_manuais_orcamento(dados_orcamento, ajustes_manuais_atuais)
            validacao_orcamento = validar_orcamento(
                arquivo_orcamento,
                dados,
                dados_orcamento,
                ignorar_complemento_manual=ignorar_complemento_manual,
            )
            if orcamento_lido_nesta_execucao and _eh_mapfre(dados):
                tentativas_modelos_orcamento = [
                    _resumo_tentativa_modelo_orcamento("mapfre_cilia", validacao_orcamento)
                ]

            if _deve_tentar_modelo_mapfre_atual(
                dados,
                arquivo_orcamento,
                validacao_orcamento,
                orcamento_lido_nesta_execucao=orcamento_lido_nesta_execucao,
                tem_ajuste_manual=tem_ajuste_manual,
            ):
                self._notificar_progresso(etapa="LENDO_ORCAMENTO_IA_MAPFRE_ATUAL")
                logger.info("PASSO1 OS %s Mapfre/CILIA divergente; tentando modelo Mapfre atual", codigo)
                dados_orcamento_atual = self.document_reader.ler_orcamento(
                    arquivo_orcamento,
                    seguradora=dados.seguradora,
                    perfil="mapfre_atual",
                )
                validacao_orcamento_atual = validar_orcamento(
                    arquivo_orcamento,
                    dados,
                    dados_orcamento_atual,
                    ignorar_complemento_manual=ignorar_complemento_manual,
                )
                tentativas_modelos_orcamento.append(
                    _resumo_tentativa_modelo_orcamento("mapfre_atual", validacao_orcamento_atual)
                )
                dados_orcamento = dados_orcamento_atual
                validacao_orcamento = validacao_orcamento_atual

            valor_franquia_tq = _valor_franquia_para_tq(dados_orcamento, dados.valor_franquia)
            exige_termo_quitacao = valor_franquia_tq is not None and valor_franquia_tq > 0

            if not exige_termo_quitacao:
                arquivo_termo = None
                dados_termo = None
            elif not dados_termo:
                self._notificar_progresso(etapa="BAIXANDO_TERMO_QUITACAO")
                print(f"PASSO1 OS {codigo} download termo quitacao iniciando", flush=True)
                logger.info("PASSO1 OS %s download termo quitacao iniciando", codigo)
                arquivo_termo = self.conference_client.download_documento(codigo, "termo_quitacao")
                self._notificar_progresso(etapa="TERMO_QUITACAO_BAIXADO", arquivo=bool(arquivo_termo))
                print(f"PASSO1 OS {codigo} download termo quitacao arquivo={bool(arquivo_termo)}", flush=True)
                logger.info("PASSO1 OS %s download termo quitacao arquivo=%s", codigo, bool(arquivo_termo))

            if exige_termo_quitacao and arquivo_termo and not dados_termo:
                self._notificar_progresso(etapa="LENDO_TERMO_QUITACAO_IA")
                print(f"PASSO1 OS {codigo} leitura IA termo quitacao iniciando", flush=True)
                logger.info("PASSO1 OS %s leitura IA termo quitacao iniciando", codigo)
                dados_termo = self.document_reader.ler_termo_quitacao(arquivo_termo)
                self._notificar_progresso(etapa="TERMO_QUITACAO_IA_OK")
                print(f"PASSO1 OS {codigo} leitura IA termo quitacao OK", flush=True)
                logger.info("PASSO1 OS %s leitura IA termo quitacao OK", codigo)

            self._notificar_progresso(etapa="VALIDANDO_REGRAS")
            print(f"PASSO1 OS {codigo} validacoes iniciando", flush=True)
            logger.info("PASSO1 OS %s validacoes iniciando", codigo)
            validacao_cnpj = self._validar_cnpj(
                dados,
                dados_orcamento,
                dados_faturamento,
            )
            validacoes = {
                "dados_conference": validar_dados_conference_basicos(dados),
                "cnpj": validacao_cnpj,
                "termo_quitacao": validar_termo_quitacao(
                    arquivo_termo,
                    dados.seguradora,
                    dados_termo,
                    valor_franquia=valor_franquia_tq,
                ),
                "orcamento": validacao_orcamento,
                "anexos": validar_anexos(
                    {},
                    [asdict(anexo) for anexo in anexos_conference],
                    tipos_obrigatorios=_tipos_anexos_obrigatorios(dados),
                ),
            }
            tentativas_valor_divergente = self._tentativas_valor_divergente(codigo, validacoes)
            status_consolidacao, acao_sugerida = classificar_consolidacao(
                validacoes,
                tentativas_valor_divergente=tentativas_valor_divergente,
            )
            ocorrencias_passo3 = _ocorrencias_passo3(
                validacoes,
                dados,
                dados_orcamento,
                status_consolidacao=status_consolidacao,
                acao_sugerida=acao_sugerida,
                tentativas_valor_divergente=tentativas_valor_divergente,
            )
            resultado = ResultadoConsolidacao(
                os=codigo,
                seguradora=dados.seguradora,
                status_consolidacao=status_consolidacao,
                acao_sugerida=acao_sugerida,
                validacoes=validacoes,
                dados_conference=asdict(dados),
                dados_extraidos={
                    "financeiro_conference": {
                        "valor_pecas": dados.valor_pecas,
                        "valor_servicos": dados.valor_servicos,
                        "valor_franquia": dados.valor_franquia,
                        "valor_total": dados.valor_total,
                    },
                    "downloads": {
                        "orcamento_final": arquivo_orcamento,
                        "termo_quitacao": arquivo_termo,
                        "dados_faturamento": arquivo_dados_faturamento,
                    },
                    "anexos_conference": [asdict(anexo) for anexo in anexos_conference],
                    "orcamento": dados_orcamento or {},
                    "termo_quitacao": dados_termo or {},
                    "dados_faturamento": dados_faturamento or {},
                    "tentativas_modelos_orcamento": tentativas_modelos_orcamento,
                    "tentativas_valor_divergente": tentativas_valor_divergente,
                    "ocorrencias_passo3": ocorrencias_passo3,
                    "ajustes_manuais": dados_extraidos_anteriores.get("ajustes_manuais") or [],
                    "ajustes_manuais_atuais": ajustes_manuais_atuais,
                },
            )
            if persistir:
                self._persistir(resultado)
            return resultado
        except Exception as exc:
            logger.exception("Erro tecnico no Passo 1 ao processar OS %s", codigo)
            dados_conference = self._buscar_snapshot_conference(codigo)
            resultado = ResultadoConsolidacao(
                os=codigo,
                seguradora=dados_conference.get("seguradora") or "",
                status_consolidacao=CONSOLIDACAO_ERRO_TECNICO,
                acao_sugerida=ACAO_ENVIAR_PASSO_2,
                validacoes={
                    "erro_tecnico": ValidacaoResultado(
                        item="erro_tecnico",
                        status=STATUS_ERRO,
                        mensagem=str(exc),
                    )
                },
                dados_conference=dados_conference,
                erros=[str(exc)],
            )
            if persistir:
                self._persistir(resultado)
            return resultado

    def _validar_cnpj(
        self,
        dados,
        dados_orcamento,
        dados_faturamento=None,
    ) -> ValidacaoResultado:
        validacao_redis = self._validacao_cnpj_tokio_redis(dados)
        if validacao_redis:
            return validacao_redis
        return validar_cnpj(
            dados,
            repository=self.repository,
            dados_orcamento=dados_orcamento,
            dados_faturamento=dados_faturamento,
        )

    def _validacao_cnpj_tokio_redis(self, dados) -> ValidacaoResultado | None:
        if not _eh_tokio(dados) or not self.cache:
            return None

        chaves = _chaves_rpa_tokio(dados)
        try:
            chave, value = _primeiro_valor_redis(self.cache.client, chaves)
        except Exception as exc:
            logger.warning("PASSO1 OS %s falha ao consultar Redis Tokio CNPJ: %s", dados.codigo or dados.os, exc)
            return None

        if not value:
            return None

        try:
            payload = json.loads(value)
        except Exception:
            logger.warning("PASSO1 OS %s Redis Tokio CNPJ com JSON invalido chave=%s", dados.os, chave)
            return None

        if not isinstance(payload, dict) or payload.get("validado") is not True:
            return None

        cnpj = _somente_numeros(payload.get("cnpj"))
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_APROVADO,
            mensagem="CNPJ Tokio validado previamente pelo RPA via Redis.",
            dados={
                "origem": "redis_rpa_tokio",
                "chave": chave,
                "verificado": payload.get("verificado") is True,
                "validado": True,
                "cnpj_site": cnpj,
            },
        )

    def _tentativas_valor_divergente(self, codigo: str, validacoes: dict) -> int:
        orcamento = validacoes.get("orcamento")
        if not orcamento or orcamento.status != STATUS_REPROVADO:
            return 0
        if not self.repository or not hasattr(self.repository, "contar_execucoes_status"):
            return 1
        return self.repository.contar_execucoes_status(
            codigo,
            CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
        ) + 1

    def _erro_sem_codigo(self, registro) -> ResultadoConsolidacao:
        return ResultadoConsolidacao(
            os="",
            seguradora=str(registro.get("seguradora") or ""),
            status_consolidacao=CONSOLIDACAO_ERRO_TECNICO,
            acao_sugerida=ACAO_ENVIAR_PASSO_2,
            validacoes={
                "erro_tecnico": ValidacaoResultado(
                    item="erro_tecnico",
                    status=STATUS_ERRO,
                    mensagem="Registro retornado pela Conference sem codigo.",
                    dados={"registro": registro},
                )
            },
        )

    def validar_orcamento_codigo(self, codigo: str):
        dados = self.conference_client.buscar_dados_os(codigo)
        arquivo = self.conference_client.download_documento(codigo, "orcamento_final")
        dados_orcamento = None
        if arquivo:
            dados_orcamento = self.document_reader.ler_orcamento(arquivo, seguradora=dados.seguradora)

        validacao = validar_orcamento(arquivo, dados, dados_orcamento)
        return {
            "codigo": codigo,
            "arquivo": arquivo,
            "dados_conference": asdict(dados),
            "dados_orcamento": dados_orcamento,
            "validacao": asdict(validacao),
        }

    def _persistir_lote(self, resultados: List[ResultadoConsolidacao]) -> None:
        if self.repository:
            self.repository.salvar_lote(resultados)
        if self.cache:
            self.cache.salvar_lote(resultados)

    def _persistir(self, resultado: ResultadoConsolidacao) -> None:
        if self.repository:
            self.repository.salvar(resultado)
        if self.cache:
            self.cache.salvar(resultado)

    def _listar_snapshots_conference(self, status: int | str | None = 5, empresa: Optional[int] = None) -> list[dict]:
        if not self.repository or not hasattr(self.repository, "listar_snapshots_conference"):
            raise RuntimeError("Repositorio nao suporta leitura de snapshots sincronizados do Conference.")
        return self.repository.listar_snapshots_conference(status=status, empresa=empresa)

    def _listar_snapshots_consolidacoes(self, status: int | str | None = 5, empresa: Optional[int] = None) -> list[dict]:
        if self.repository and hasattr(self.repository, "listar_snapshots_consolidacoes"):
            return self.repository.listar_snapshots_consolidacoes(status=status, empresa=empresa)
        return self._listar_snapshots_conference(status=status, empresa=empresa)

    def _cache_snapshot_conference(self, codigo: str) -> None:
        snapshot = self._buscar_snapshot_conference(codigo)
        if not snapshot:
            raise RuntimeError("Snapshot do Conference nao encontrado na base. Execute a sincronizacao antes do Passo 1.")
        self.conference_client.cache_sinistro(snapshot)

    def _buscar_snapshot_conference(self, codigo: str) -> dict:
        if not self.repository or not hasattr(self.repository, "buscar_snapshot_conference"):
            return {}
        return self.repository.buscar_snapshot_conference(codigo)

    def _verificar_cancelamento(self) -> None:
        if self.cancel_checker and self.cancel_checker():
            raise Passo1Cancelado("Execucao do Passo 1 cancelada.")

    def _notificar_progresso(self, **dados) -> None:
        if not self.progress_callback:
            return
        payload = dict(self._progress_context)
        payload.update({key: value for key, value in dados.items() if value is not None})
        try:
            self.progress_callback(payload)
        except Exception:
            logger.exception("Falha ao registrar progresso do Passo 1")

    def _buscar_dados_extraidos(self, codigo: str) -> dict:
        if self.repository and hasattr(self.repository, "buscar_dados_extraidos_por_os"):
            return self.repository.buscar_dados_extraidos_por_os(codigo)
        return {}

    def _buscar_anexos_conference(self, codigo: str):
        if not hasattr(self.conference_client, "consultar_sinistros_anexos"):
            return []
        try:
            resposta = self.conference_client.consultar_sinistros_anexos(codigo)
            anexos = self.conference_client.normalizar_registros(resposta.get("dados"))
            return [
                _documento_from_anexo(anexo)
                for anexo in anexos
            ]
        except Exception:
            return []

    def _buscar_aprovado(self, codigo: str) -> ResultadoConsolidacao | None:
        if not self.repository or not hasattr(self.repository, "buscar_por_os"):
            return None

        resultado = self.repository.buscar_por_os(codigo)
        if self._ja_estava_aprovado(resultado):
            return resultado
        return None

    def _ja_estava_aprovado(self, resultado: ResultadoConsolidacao | None) -> bool:
        return bool(resultado and resultado.status_consolidacao == CONSOLIDACAO_APROVADA)


def _ocorrencias_passo3(
    validacoes: dict,
    dados,
    dados_orcamento: dict | None,
    status_consolidacao: str | None = None,
    acao_sugerida: str | None = None,
    tentativas_valor_divergente: int = 0,
) -> list[dict]:
    ocorrencias = []
    seguradora = dados.seguradora or "seguradora"
    cnpj = getattr(dados, "cnpj_seguradora", None)
    anexos = validacoes.get("anexos")
    termo = validacoes.get("termo_quitacao")
    cnpj_validacao = validacoes.get("cnpj")
    orcamento = validacoes.get("orcamento")
    valores_orcamento = ((orcamento.dados or {}).get("orcamento") if orcamento else None) or {}
    data_orcamento = valores_orcamento.get("data_orcamento") or _data_orcamento(dados_orcamento)

    if anexos and anexos.status == STATUS_REPROVADO and "C27" not in OCORRENCIAS_DESATIVADAS:
        ocorrencias.append(_ocorrencia("C27", _mensagem_anexos_reprovados(anexos), "anexos"))

    if cnpj_validacao and cnpj_validacao.status == STATUS_APROVADO and cnpj:
        cnpj_formatado = _format_cnpj(cnpj)
        ocorrencias.extend(
            [
                _ocorrencia(
                    "C14",
                    f"CNPJ {cnpj_formatado} esta Ativo, conforme consulta direta na Receita Federal.",
                    "cnpj",
                ),
                _ocorrencia(
                    "C15",
                    f"Processo será faturado no CNPJ {cnpj_formatado} conforme região",
                    "cnpj",
                ),
                _ocorrencia(
                    "C16",
                    f"O CNPJ {cnpj_formatado} confere com a empresa cadastrada.",
                    "cnpj",
                ),
            ]
        )
    elif cnpj_validacao and cnpj_validacao.status == STATUS_REPROVADO:
        ocorrencias.append(_ocorrencia(_id_cnpj_reprovado(cnpj_validacao), _mensagem_cnpj_reprovado(cnpj_validacao), "cnpj"))

    if termo and termo.status == STATUS_APROVADO and not _termo_dispensado(termo):
        seguradora_termo = _seguradora_termo(termo) or seguradora
        ocorrencias.append(
            _ocorrencia(
                "C05",
                f"TQ está no nome da seguradora {seguradora_termo} e assinado pelo segurado. OK, verificado.",
                "termo_quitacao",
                chave="msgTQ",
            )
        )
    elif termo and termo.status == STATUS_REPROVADO:
        ocorrencias.append(_ocorrencia(_id_termo_reprovado(termo), _mensagem_termo_reprovado(termo), "termo_quitacao"))
    elif termo and termo.status == STATUS_PENDENTE:
        ocorrencias.append(
            _ocorrencia(
                "C01",
                "Termo de quitacao encontrado, mas nao foi possivel extrair dados com IA.",
                "termo_quitacao",
            )
        )

    if orcamento and orcamento.status == STATUS_APROVADO:
        ocorrencias.extend(
            [
                _ocorrencia(
                    "C08",
                    f"Orçamento FINAL inserido pelo consultor em sistema confere com a última versão de orçamento disponível no portal {seguradora}. OK, verificado.",
                    "orcamento",
                ),
                _ocorrencia(
                    "C10",
                    f"Valor total para faturar à Cia em Sistema, confere com a ultima versão do orçamento autorizado em {data_orcamento} e consulta efetuada no portal {seguradora}.",
                    "orcamento",
                ),
                _ocorrencia(
                    "C11",
                    f"Autorização de emissão de nota fiscal para a seguradora {seguradora}.",
                    "orcamento",
                ),
            ]
        )
    elif orcamento and orcamento.status == STATUS_REPROVADO:
        mensagem_orcamento = (
            'Orçamento Allianz sem a tarja "Vistoria Autorizada Final". Favor anexar '
            "o orçamento final autorizado."
            if _orcamento_sem_tarja_allianz(orcamento)
            else "Orçamento FINAL inserido pelo consultor em sistema está com divergência "
            "de valores. Favor conferir."
        )
        ocorrencias.append(
            _ocorrencia(
                _id_orcamento_reprovado(orcamento),
                mensagem_orcamento,
                "orcamento",
            )
        )
    elif orcamento and orcamento.status == STATUS_PENDENTE:
        ocorrencias.append(_ocorrencia(_id_orcamento_pendente(orcamento), _mensagem_orcamento_pendente(orcamento), "orcamento"))

    ocorrencias.extend(
        _ocorrencias_operacionais(
            status_consolidacao=status_consolidacao,
            acao_sugerida=acao_sugerida,
            tentativas_valor_divergente=tentativas_valor_divergente,
            orcamento_validacao=orcamento,
        )
    )

    if _validacoes_principais_aprovadas(validacoes):
        ocorrencias.append(
            _ocorrencia(
                "C12",
                "Processo finalizado com sucesso via IA. Dados verificados. OK conferido.",
                "finalizacao",
            )
        )

    ocorrencias = _filtrar_ocorrencias_reprovacao(ocorrencias, status_consolidacao)
    return _dedupe_ocorrencias(ocorrencias)


def _resultado_complementar(codigo: str, dados) -> ResultadoConsolidacao:
    complemento = _indicador_complemento_passo1(dados)
    validacoes = {
        "orcamento": ValidacaoResultado(
            item="orcamento",
            status=STATUS_PENDENTE,
            mensagem="OS com complemento no Conference exige verificacao manual.",
            dados={
                "complemento": complemento,
                "conference": dados.raw,
            },
        )
    }
    return ResultadoConsolidacao(
        os=codigo,
        seguradora=dados.seguradora,
        status_consolidacao=CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
        acao_sugerida=ACAO_FECHAR_MANUAL,
        validacoes=validacoes,
        dados_conference=asdict(dados),
        dados_extraidos={
            "financeiro_conference": {
                "valor_pecas": dados.valor_pecas,
                "valor_servicos": dados.valor_servicos,
                "valor_franquia": dados.valor_franquia,
                "valor_total": dados.valor_total,
            },
            "downloads": {},
            "anexos_conference": [],
            "orcamento": {},
            "termo_quitacao": {},
            "ocorrencias_passo3": _ocorrencias_operacionais(
                CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
                ACAO_FECHAR_MANUAL,
                0,
            ),
        },
    )


def _eh_allianz(dados) -> bool:
    seguradora = _normalizar_texto(getattr(dados, "seguradora", None))
    if "allianz" in seguradora or "allanz" in seguradora:
        return True
    return _somente_numeros(getattr(dados, "cnpj_seguradora", None)) in ALLIANZ_CNPJS


def _eh_tokio(dados) -> bool:
    return _normalizar_texto(getattr(dados, "seguradora", None)).startswith("tokio")


def _chaves_rpa_tokio(dados) -> list[str]:
    valores = [
        getattr(dados, "codigo", None),
        ((getattr(dados, "raw", None) or {}).get("codigo") if isinstance(getattr(dados, "raw", None), dict) else None),
        getattr(dados, "os", None),
    ]
    chaves = []
    for valor in valores:
        valor = str(valor or "").strip()
        if valor and valor not in chaves:
            chaves.append(valor)
    return [f"rpa_tokio:{valor}" for valor in chaves]


def _primeiro_valor_redis(client, chaves: list[str]):
    for chave in chaves:
        value = client.get(chave)
        if value:
            return chave, value
    return (chaves[0] if chaves else "", None)


def _dados_indicam_complementar(dados) -> bool:
    return bool(_indicador_complemento_passo1(dados).get("manual"))


def _indicador_complemento_passo1(dados) -> dict:
    raw = dados.raw or {}
    aliases = [
        "complemento",
        "complementar",
        "tem_complemento",
        "possui_complemento",
        "orcamento_complementar",
        "complemento_orcamento",
        "ind_complemento",
    ]
    for campo in aliases:
        if campo in raw:
            valor = raw.get(campo)
            return {
                "manual": _valor_indica_sim(valor),
                "campo": campo,
                "valor": valor,
            }

    valor = getattr(dados, "complemento", None)
    return {
        "manual": _valor_indica_sim(valor),
        "campo": "complemento",
        "valor": valor,
    }


def _valor_indica_sim(value) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value == 1
    if value is None:
        return False

    texto = str(value).strip().lower()
    if not texto:
        return False
    return texto in {"1", "s", "sim", "true", "t", "yes", "y"}


def _ocorrencia(identificador: str, comentario: str, origem: str, chave: str | None = None) -> dict:
    payload = {"id": identificador, "comentario": comentario, "origem": origem}
    if chave:
        payload["chave"] = chave
    return payload


def _filtrar_ocorrencias_reprovacao(ocorrencias: list[dict], status_consolidacao: str | None) -> list[dict]:
    return _filtrar_ocorrencias_desativadas(ocorrencias)


def _id_termo_reprovado(termo: ValidacaoResultado) -> str:
    mensagem = (termo.mensagem or "").lower()
    if "sem assinatura" in mensagem:
        return "C04"
    if "seguradora" in mensagem:
        return "C03"
    if "nao foi encontrado" in mensagem or "não foi encontrado" in mensagem:
        return "C02"
    return "C01"


def _mensagem_termo_reprovado(termo: ValidacaoResultado) -> str:
    mensagem = termo.mensagem or ""
    if "sem assinatura" in mensagem.lower():
        return "TQ não assinado. Favor corrigir."
    if "seguradora" in mensagem.lower():
        return "TQ não confere. Nome da seguradora está incorreto."
    if "nao foi encontrado" in mensagem.lower() or "não foi encontrado" in mensagem.lower():
        return "O arquivo TERMO DE QUITAÇÃO não foi encontrado."
    return mensagem or "TQ não confere. Favor corrigir."


def _id_orcamento_reprovado(orcamento: ValidacaoResultado) -> str:
    mensagem = (orcamento.mensagem or "").lower()
    if "nao foi encontrado" in mensagem or "não foi encontrado" in mensagem:
        return "C07"
    return "C09"


def _id_orcamento_pendente(orcamento: ValidacaoResultado) -> str:
    complemento = ((orcamento.dados or {}).get("complemento") or {}).get("manual")
    return "C25" if complemento else "C01"


def _mensagem_orcamento_pendente(orcamento: ValidacaoResultado) -> str:
    complemento = ((orcamento.dados or {}).get("complemento") or {}).get("manual")
    if complemento:
        return "OS com complemento identificado no Conference. Fechamento deve ser realizado manualmente."
    return orcamento.mensagem or "{mensagem do checkpoint}"


def _id_cnpj_reprovado(cnpj_validacao: ValidacaoResultado) -> str:
    mensagem = (cnpj_validacao.mensagem or "").lower()
    if "diverge" in mensagem or "nao confere" in mensagem or "não confere" in mensagem:
        return "C17"
    return "C13"


def _mensagem_cnpj_reprovado(cnpj_validacao: ValidacaoResultado) -> str:
    mensagem = (cnpj_validacao.mensagem or "").lower()
    if "diverge" in mensagem or "nao confere" in mensagem or "não confere" in mensagem:
        cnpj_correto = _cnpj_correto(cnpj_validacao)
        return f"A NF deve ser faturada no CNPJ {cnpj_correto}. OS Reprovada, favor ajustar."
    return "O CNPJ da seguradora está inativo ou inválido."


def _mensagem_anexos_reprovados(anexos: ValidacaoResultado) -> str:
    faltantes = ((anexos.dados or {}).get("faltantes") or [])
    nomes = ", ".join(_nome_anexo_faltante(item) for item in faltantes if item)
    if nomes:
        return f"Anexos obrigatórios não foram encontrados: {nomes}. OS Reprovada, favor anexar os documentos."
    return anexos.mensagem or "Anexos obrigatórios não foram encontrados. OS Reprovada, favor anexar os documentos."


def _mensagem_valor_divergente(orcamento: ValidacaoResultado | None) -> str:
    valor_total = (((orcamento.dados if orcamento else {}) or {}).get("orcamento") or {}).get("valor_total")
    return (
        "A IA identificou divergência no valor total da OS lançada no NBS e no Orçamento anexado. "
        f"O Total verificado pela IA é de {_format_money_br(valor_total)}, diferente do informado na OS. "
        "Favor realizar a correção."
    )


def _orcamento_tem_divergencia_campo(orcamento: ValidacaoResultado | None, campo: str) -> bool:
    comparacoes = ((orcamento.dados if orcamento else {}) or {}).get("comparacoes") or []
    for comparacao in comparacoes:
        if comparacao.get("campo") == campo and comparacao.get("confere") is False:
            return True
    return False


def _nome_anexo_faltante(value) -> str:
    nomes = {
        "fotos": "fotos",
        "nf_fabrica": "NF de fábrica",
        "conhecimento_transporte": "conhecimento de transporte",
        "orcamento_final": "orçamento final",
        "termo_quitacao": "termo de quitação",
        "dados_faturamento": "Dados para Faturamento",
    }
    return nomes.get(str(value), str(value).replace("_", " "))


def _cnpj_correto(cnpj_validacao: ValidacaoResultado) -> str:
    dados = cnpj_validacao.dados or {}
    return _format_cnpj(
        dados.get("cnpj_orcamento")
        or dados.get("cnpj_correto")
        or dados.get("cnpj_seguradora")
        or dados.get("cnpj_conference")
        or ""
    )


def _ocorrencias_operacionais(
    status_consolidacao: str | None,
    acao_sugerida: str | None,
    tentativas_valor_divergente: int,
    orcamento_validacao: ValidacaoResultado | None = None,
) -> list[dict]:
    ocorrencias = []
    if status_consolidacao == CONSOLIDACAO_APROVADA:
        ocorrencias.append(
            _ocorrencia(
                "C20",
                "OS validada automaticamente. Autorização de emissão de nota será executada pelo RPA.",
                "automatizacao",
            )
        )
    if status_consolidacao == CONSOLIDACAO_PENDENTE_BATIMENTO and "C22" not in OCORRENCIAS_DESATIVADAS:
        ocorrencias.append(
            _ocorrencia(
                "C22",
                "OS retornada para revisão pela oficina após pendência no batimento humano.",
                "retorno",
            )
        )
    if status_consolidacao == CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE:
        if _orcamento_sem_tarja_allianz(orcamento_validacao):
            return _dedupe_ocorrencias(ocorrencias)
        tem_divergencia_total = _orcamento_tem_divergencia_campo(orcamento_validacao, "valor_total")
        tem_divergencia_franquia = _orcamento_tem_divergencia_campo(orcamento_validacao, "valor_franquia")
        if tem_divergencia_total or not (tem_divergencia_total or tem_divergencia_franquia):
            ocorrencias.append(
                _ocorrencia(
                    "C23",
                    _mensagem_valor_divergente(orcamento_validacao),
                    "valor_divergente",
                )
            )
        if tem_divergencia_franquia:
            ocorrencias.append(
                _ocorrencia(
                    "C28",
                    MENSAGEM_VALOR_FRANQUIA_DIVERGENTE,
                    "valor_franquia_divergente",
                )
            )
    if status_consolidacao == CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL:
        manual_por_reincidencia = tentativas_valor_divergente >= 3
        ocorrencias.append(
            _ocorrencia(
                "C25",
                (
                    "OS reprovada por divergência de valores em 3 verificações. "
                    "O processo deve ser tratado manualmente."
                    if manual_por_reincidencia
                    else "OS com complemento identificado no Conference. Fechamento deve ser realizado manualmente."
                ),
                "reincidencia_valor" if manual_por_reincidencia else "complemento",
            )
        )
    if status_consolidacao == CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO:
        ocorrencias.append(
            _ocorrencia(
                "C26",
                "CNPJ divergente ou inválido na validação. OS reprovada automaticamente.",
                "cnpj",
            )
        )
    return _dedupe_ocorrencias(ocorrencias)


def _orcamento_sem_tarja_allianz(orcamento: ValidacaoResultado | None) -> bool:
    return bool(
        orcamento
        and (orcamento.dados or {}).get("vistoria_autorizada_final") is False
    )


def _filtrar_ocorrencias_desativadas(ocorrencias: list[dict]) -> list[dict]:
    return [ocorrencia for ocorrencia in ocorrencias if ocorrencia.get("id") not in OCORRENCIAS_DESATIVADAS]


def _valor_franquia_para_tq(dados_orcamento: dict | None, valor_franquia_conference):
    valor_orcamento = _valor_franquia_efetiva_orcamento(dados_orcamento or {}, valor_franquia_conference)
    if valor_orcamento is not None:
        return valor_orcamento
    return valor_franquia_conference


def _aplicar_ajustes_manuais_orcamento(dados_orcamento: dict | None, ajustes: dict | None) -> dict | None:
    if not dados_orcamento or not ajustes:
        return dados_orcamento

    ajustado = deepcopy(dados_orcamento)
    if set(ajustado) == {"total_franquia", "total_pecas", "total_mo", "total_geral"}:
        campos_sompo = {
            "valor_pecas": "total_pecas",
            "valor_servicos": "total_mo",
            "valor_franquia": "total_franquia",
            "valor_total": "total_geral",
        }
        for campo, ajuste in (ajustes or {}).items():
            campo_sompo = campos_sompo.get(campo)
            valor = (ajuste or {}).get("valorNormalizado")
            if campo_sompo and valor is not None:
                ajustado[campo_sompo] = valor
        return ajustado

    base = _orcamento_base_payload(ajustado)
    totais = base.setdefault("totais", {})
    faturar = totais.setdefault("faturar", {})
    deducoes = base.setdefault("deducoes", {})

    for campo, ajuste in (ajustes or {}).items():
        valor = (ajuste or {}).get("valorNormalizado")
        if campo == "cnpj":
            cnpj = str((ajuste or {}).get("valor") or "").strip()
            if cnpj:
                dados_faturamento = ajustado.setdefault("dadosFaturamento", {})
                dados_faturamento["cnpj"] = cnpj
        elif campo == "valor_pecas" and valor is not None:
            faturar["pecas"] = valor
        elif campo == "valor_servicos" and valor is not None:
            faturar["servicos"] = valor
        elif campo == "valor_franquia" and valor is not None:
            deducoes["franquia_bruta"] = valor
            deducoes["total"] = valor

    return ajustado


def _orcamento_base_payload(dados_orcamento: dict) -> dict:
    orcamentos = dados_orcamento.get("orcamento") or []
    if orcamentos:
        return orcamentos[0] or {}
    return dados_orcamento.setdefault("liberado", {})


def _tipos_anexos_obrigatorios(dados) -> list[str]:
    obrigatorios = []
    if _eh_all_risk(dados):
        obrigatorios.extend(["fotos", "nf_fabrica", "conhecimento_transporte"])
    if _eh_allianz(dados):
        obrigatorios.append("dados_faturamento")
    return obrigatorios


def _eh_all_risk(dados) -> bool:
    return not str(getattr(dados, "placa", "") or "").strip()


def _documento_from_anexo(anexo: dict) -> Documento:
    nome = _primeiro_valor(anexo, ["tipo", "descricao", "nome", "arquivo", "titulo"]) or ""
    return Documento(
        tipo=str(nome),
        nome=str(nome),
        arquivo=None,
        metadados={
            "codigo": _primeiro_valor(anexo, ["codigo", "codigo_anexo", "id"]),
            "raw": anexo,
        },
    )


def _codigo_registro(registro: dict) -> str:
    return str(_primeiro_valor(registro, ["codigo", "os", "ordem_servico", "numero_os"]) or "")


def _primeiro_valor(registro: dict, campos: list[str]):
    for campo in campos:
        valor = registro.get(campo)
        if valor not in (None, ""):
            return valor
    return None


def _somente_numeros(value):
    if value in (None, ""):
        return None
    return "".join(ch for ch in str(value) if ch.isdigit()) or None


def _normalizar_texto(value) -> str:
    return (
        str(value or "")
        .strip()
        .lower()
        .replace("á", "a")
        .replace("à", "a")
        .replace("ã", "a")
        .replace("â", "a")
        .replace("é", "e")
        .replace("ê", "e")
        .replace("í", "i")
        .replace("ó", "o")
        .replace("ô", "o")
        .replace("õ", "o")
        .replace("ú", "u")
        .replace("ç", "c")
    )


def _eh_mapfre(dados) -> bool:
    return "mapfre" in _normalizar_texto(getattr(dados, "seguradora", "") or "")


def _deve_tentar_modelo_mapfre_atual(
    dados,
    arquivo_orcamento,
    validacao_orcamento: ValidacaoResultado,
    orcamento_lido_nesta_execucao: bool,
    tem_ajuste_manual: bool,
) -> bool:
    return bool(
        _eh_mapfre(dados)
        and arquivo_orcamento
        and orcamento_lido_nesta_execucao
        and not tem_ajuste_manual
        and validacao_orcamento.status in {STATUS_REPROVADO, STATUS_PENDENTE}
    )


def _resumo_tentativa_modelo_orcamento(
    perfil: str,
    validacao: ValidacaoResultado,
) -> dict:
    dados = validacao.dados or {}
    return {
        "perfil": perfil,
        "status": validacao.status,
        "mensagem": validacao.mensagem,
        "comparacoes": dados.get("comparacoes") or [],
        "orcamento": dados.get("orcamento") or {},
    }


def _valor_franquia_efetiva_orcamento(dados_orcamento: dict, valor_franquia_conference=None):
    if set(dados_orcamento) == {"total_franquia", "total_pecas", "total_mo", "total_geral"}:
        return _abs_or_none(_float_or_none(dados_orcamento.get("total_franquia")))

    base = _orcamento_base_tq(dados_orcamento)
    if not base:
        return None

    totais = base.get("totais") or {}
    faturar = totais.get("faturar") or {}
    deducoes = base.get("deducoes") or {}
    servicos = _float_or_none(totais.get("liquido_mao_obra"))
    if servicos is None:
        servicos = _float_or_none(faturar.get("servicos"))
    pecas = _float_or_none(faturar.get("pecas"))
    total = _float_or_none(faturar.get("total"))
    franquia = _abs_or_none(_float_or_none(deducoes.get("franquia_bruta")))
    franquia_totalizador = _abs_or_none(_float_or_none(deducoes.get("total")))
    franquia_calculada = None
    if servicos is not None and pecas is not None and total is not None:
        franquia_calculada = round(servicos + pecas - total, 2)

    for valor in (franquia, franquia_totalizador, franquia_calculada):
        if _valores_conferem(valor_franquia_conference, valor):
            return valor
    if franquia_totalizador is not None:
        return franquia_totalizador
    if franquia_calculada is not None:
        return franquia_calculada
    if franquia is not None:
        return franquia
    return None


def _valores_conferem(valor_a, valor_b, tolerancia: float = 0.01) -> bool:
    if valor_a is None or valor_b is None:
        return False
    return abs(round(float(valor_a) - float(valor_b), 2)) <= tolerancia


def _orcamento_base_tq(dados_orcamento: dict):
    orcamentos = dados_orcamento.get("orcamento") or []
    if orcamentos:
        return orcamentos[0] or {}
    return dados_orcamento.get("liberado") or {}


def _float_or_none(value):
    if value in (None, ""):
        return None
    try:
        if isinstance(value, str):
            value = value.strip()
            negative = value.startswith("-") or ("(" in value and ")" in value)
            value = (
                value.replace("R$", "")
                .replace("$", "")
                .replace("(", "")
                .replace(")", "")
                .replace("-", "")
                .strip()
            )
            if "," in value:
                value = value.replace(".", "").replace(",", ".")
            number = float(value)
            return -number if negative else number
        return float(value)
    except (TypeError, ValueError):
        return None


def _abs_or_none(value):
    if value is None:
        return None
    return abs(value)


def _dedupe_ocorrencias(ocorrencias: list[dict]) -> list[dict]:
    vistos = set()
    deduped = []
    for ocorrencia in ocorrencias:
        chave = (ocorrencia.get("id"), ocorrencia.get("comentario"))
        if chave in vistos:
            continue
        vistos.add(chave)
        deduped.append(ocorrencia)
    return deduped


def _validacoes_principais_aprovadas(validacoes: dict) -> bool:
    nomes = ("cnpj", "termo_quitacao", "orcamento")
    return all(validacoes.get(nome) and validacoes[nome].status == STATUS_APROVADO for nome in nomes)


def _termo_dispensado(termo: ValidacaoResultado) -> bool:
    return bool((termo.dados or {}).get("dispensado"))


def _seguradora_termo(termo: ValidacaoResultado) -> str | None:
    return (((termo.dados or {}).get("dados") or {}).get("seguradora") or "").strip() or None


def _data_orcamento(dados_orcamento: dict | None) -> str:
    return ((dados_orcamento or {}).get("dados") or {}).get("dataOrcamento") or "data nao informada"


def _format_cnpj(value) -> str:
    digits = "".join(char for char in str(value or "") if char.isdigit())
    if len(digits) != 14:
        return str(value or "")
    return f"{digits[:2]}.{digits[2:5]}.{digits[5:8]}/{digits[8:12]}-{digits[12:]}"


def _format_money_br(value) -> str:
    try:
        number = float(value or 0)
    except (TypeError, ValueError):
        number = 0.0
    formatted = f"{number:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return f"R$ {formatted}"


class Passo1Cancelado(RuntimeError):
    pass
