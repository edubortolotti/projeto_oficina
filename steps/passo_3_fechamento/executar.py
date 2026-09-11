import logging
from dataclasses import asdict, dataclass, field
from datetime import datetime
from typing import Dict, List, Optional

from core.status import (
    CONSOLIDACAO_APROVADA,
    CONSOLIDACAO_PENDENTE_BATIMENTO,
    CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
    CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO,
    CONSOLIDACAO_REPROVADA_FALTA_ANEXO,
    CONSOLIDACAO_REPROVADA_TERMO_INVALIDO,
    CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
)


DECISAO_APROVAR = "APROVAR"
DECISAO_RETORNAR = "RETORNAR_OFICINA"
DECISAO_MANUAL = "FECHAR_MANUAL"

STATUS_FECHADA_APROVADA = "FECHADA_APROVADA"
STATUS_FECHADA_REPROVADA_RETORNO_OFICINA = "FECHADA_REPROVADA_RETORNO_OFICINA"
STATUS_FECHADA_ANALISE_MANUAL = "FECHADA_ANALISE_MANUAL"
STATUS_ERRO_FECHAMENTO = "ERRO_FECHAMENTO"

logger = logging.getLogger(__name__)


OCORRENCIAS_DESATIVADAS = {"C22", "C27"}


@dataclass
class OcorrenciaFechamento:
    comentario: str


@dataclass
class AnexoFechamento:
    tipo: str
    arquivo_id: str


@dataclass
class ComandoFechamento:
    os: str
    decisao: str
    valor_aprovado: Optional[float] = None
    ocorrencias: List[OcorrenciaFechamento] = field(default_factory=list)
    anexos: List[AnexoFechamento] = field(default_factory=list)
    metadados: Dict = field(default_factory=dict)


class Passo3Fechamento:
    def __init__(self, conference_client, repository, cache=None):
        self.conference_client = conference_client
        self.repository = repository
        self.cache = cache

    def executar_fila(self, limit: int = 100, dry_run: bool = False, automaticos: bool = False) -> dict:
        contextos = self.repository.listar_fila_fechamento(limit=limit, automaticos=automaticos)
        total = len(contextos)
        _trace(
            "PASSO3 fila total=%s limit=%s dry_run=%s automaticos=%s",
            total,
            limit,
            dry_run,
            automaticos,
        )
        resultados = []
        for indice, contexto in enumerate(contextos, start=1):
            os_number = contexto.get("os") or ""
            _trace(
                "PASSO3 OS %s iniciando (%s/%s) status=%s acao=%s curador=%s",
                os_number,
                indice,
                total,
                contexto.get("statusConsolidacao"),
                contexto.get("acaoSugerida"),
                bool(contexto.get("curadorAprovado")),
            )
            resultado = self.executar_contexto(contexto, dry_run=dry_run)
            fechamento = resultado.get("fechamento") or {}
            _trace(
                "PASSO3 OS %s finalizada ok=%s decisao=%s status_fechamento=%s erro=%s (%s/%s)",
                os_number,
                resultado.get("ok"),
                fechamento.get("decisao") or (resultado.get("comando") or {}).get("decisao"),
                fechamento.get("statusFechamento"),
                resultado.get("erro") or "",
                indice,
                total,
            )
            resultados.append(resultado)
        _trace("PASSO3 fila concluida total=%s", len(resultados))
        return {
            "ok": True,
            "dryRun": dry_run,
            "automaticos": automaticos,
            "total": len(resultados),
            "resultados": resultados,
        }

    def executar_os(self, os_number: str, dry_run: bool = False) -> dict:
        _trace("PASSO3 OS %s busca contexto dry_run=%s", os_number, dry_run)
        contexto = self.repository.buscar_contexto_fechamento(os_number)
        if not contexto:
            _trace("PASSO3 OS %s contexto nao encontrado", os_number)
            return {"ok": False, "os": os_number, "erro": "OS nao encontrada para fechamento."}
        resultado = self.executar_contexto(contexto, dry_run=dry_run)
        fechamento = resultado.get("fechamento") or {}
        _trace(
            "PASSO3 OS %s finalizada ok=%s decisao=%s status_fechamento=%s erro=%s",
            os_number,
            resultado.get("ok"),
            fechamento.get("decisao") or (resultado.get("comando") or {}).get("decisao"),
            fechamento.get("statusFechamento"),
            resultado.get("erro") or "",
        )
        return resultado

    def executar_contexto(self, contexto: dict, dry_run: bool = False) -> dict:
        comando = self._comando_from_contexto(contexto)
        _trace(
            "PASSO3 OS %s comando decisao=%s ocorrencias=%s anexos=%s dry_run=%s",
            comando.os,
            comando.decisao,
            len(comando.ocorrencias),
            len(comando.anexos),
            dry_run,
        )
        if dry_run:
            return {
                "ok": True,
                "dryRun": True,
                "comando": asdict(comando),
            }

        try:
            if comando.decisao == DECISAO_APROVAR:
                return self._aprovar(comando)
            if comando.decisao == DECISAO_RETORNAR:
                return self._retornar(comando)
            return self._manual(comando)
        except Exception as exc:
            return self._registrar_erro(comando, exc)

    def executar(self, comando: ComandoFechamento):
        if comando.decisao == DECISAO_APROVAR:
            return self._aprovar(comando)
        if comando.decisao == DECISAO_RETORNAR:
            return self._retornar(comando)
        return self._manual(comando)

    def _aprovar(self, comando: ComandoFechamento) -> dict:
        if not (comando.metadados or {}).get("curadorAprovado"):
            raise RuntimeError("Aprovacao no Passo 3 exige aprovacao previa do curador.")

        codigo = _codigo_conference(comando)
        obs = (comando.metadados or {}).get("obs") or _comentario_principal(
            comando,
            "OS validada para autorizacao de emissao de nota.",
        )
        valor_bruto_mo = comando.valor_aprovado or 0
        _validar_dados_autorizacao_nf(obs, valor_bruto_mo)

        _trace("PASSO3 OS %s registrando ocorrencias aprovacao total=%s", comando.os, len(comando.ocorrencias))
        ocorrencias_response = self._registrar_ocorrencias(comando)

        _trace("PASSO3 OS %s autorizando emissao NF valor_mo=%s", comando.os, valor_bruto_mo)
        fechamento_response = self.conference_client.autorizar_emissao_nf(
            codigo=codigo,
            obs=obs,
            valor_bruto_mo=valor_bruto_mo,
        )
        _validar_retorno_conference(fechamento_response, "autorizar_emissao_nf")

        return self._salvar(
            comando,
            STATUS_FECHADA_APROVADA,
            {
                "ocorrencias": ocorrencias_response,
                "payloadAutorizacao": {
                    "codigo": codigo,
                    "obs": obs,
                    "valor_bruto_mo": _format_decimal(valor_bruto_mo),
                },
                "fechamento": fechamento_response,
            },
        )

    def _retornar(self, comando: ComandoFechamento) -> dict:
        codigo = _codigo_conference(comando)
        _trace("PASSO3 OS %s registrando ocorrencias retorno total=%s", comando.os, len(comando.ocorrencias))
        ocorrencias_response = self._registrar_ocorrencias(comando)

        _trace("PASSO3 OS %s reiniciando reparo no Conference", comando.os)
        retorno_response = self.conference_client.reiniciar_reparo(codigo=codigo)
        _validar_retorno_conference(retorno_response, "reiniciar_reparo")

        return self._salvar(
            comando,
            STATUS_FECHADA_REPROVADA_RETORNO_OFICINA,
            {
                "ocorrencias": ocorrencias_response,
                "retorno": retorno_response,
            },
        )

    def _manual(self, comando: ComandoFechamento) -> dict:
        _trace("PASSO3 OS %s marcado para fechamento manual", comando.os)
        return self._salvar(
            comando,
            STATUS_FECHADA_ANALISE_MANUAL,
            {"mensagem": "Fechamento manual solicitado; Conference nao foi acionado."},
        )

    def _registrar_erro(self, comando: ComandoFechamento, exc: Exception) -> dict:
        mensagem = _mensagem_erro_fechamento(comando, exc)
        _trace("PASSO3 OS %s erro=%s", comando.os, mensagem)
        return self._salvar(
            comando,
            STATUS_ERRO_FECHAMENTO,
            {"erro": mensagem, "erroOriginal": str(exc)},
            erro=mensagem,
        )

    def _registrar_ocorrencias(self, comando: ComandoFechamento) -> list[dict]:
        responses = []
        ocorrencias = comando.ocorrencias or [
            OcorrenciaFechamento(comentario="OS processada pelo RPA ATRI.")
        ]
        for ocorrencia in ocorrencias:
            _trace("PASSO3 OS %s ocorrencia: %s", comando.os, ocorrencia.comentario)
            response = self.conference_client.cadastrar_ocorrencia_sinistros(
                codigo=_codigo_conference(comando),
                descricao=ocorrencia.comentario,
                data_programacao=_hoje(),
            )
            _validar_retorno_conference(response, "cadastrar_ocorrencia_sinistros")
            responses.append(
                {
                    "comentario": ocorrencia.comentario,
                    "resposta": response,
                }
            )
        return responses

    def _salvar(self, comando: ComandoFechamento, status: str, resposta_api: dict, erro: str | None = None) -> dict:
        _trace("PASSO3 OS %s salvando fechamento status=%s erro=%s", comando.os, status, erro or "")
        registro = self.repository.salvar_fechamento(
            fechamento_id=(comando.metadados or {}).get("fechamentoId"),
            os_number=comando.os,
            decisao=comando.decisao,
            status_fechamento=status,
            valor_aprovado=comando.valor_aprovado,
            ocorrencias=[asdict(ocorrencia) for ocorrencia in comando.ocorrencias],
            anexos=[asdict(anexo) for anexo in comando.anexos],
            resposta_api=resposta_api,
            erro=erro,
        )
        return {
            "ok": erro is None,
            "fechamento": registro,
            "respostaApi": resposta_api,
            "erro": erro,
        }

    def _comando_from_contexto(self, contexto: dict) -> ComandoFechamento:
        dados_conference = contexto.get("dadosConference") or {}
        dados_extraidos = contexto.get("dadosExtraidos") or {}
        financeiro = dados_extraidos.get("financeiro_conference") or {}
        decisao_humana = contexto.get("decisaoHumana") or {}
        acao = contexto.get("acaoSugerida")

        status_consolidacao = contexto.get("statusConsolidacao")

        if decisao_humana.get("decisao") == "VOLTAR_OS":
            ocorrencias_redis = _filtrar_ocorrencias_contexto(
                contexto,
                self._buscar_ocorrencias_passo3(contexto),
            )
            comentario_humano = decisao_humana.get("observacao") or (
                decisao_humana.get("dadosDecisao") or {}
            ).get("ocorrencia")
            mensagens = _mensagens_redis(ocorrencias_redis)
            if comentario_humano:
                mensagens.insert(0, comentario_humano)
            if not mensagens:
                mensagens = ["OS retornada por decisao da curadoria."]
            ocorrencias = [OcorrenciaFechamento(comentario=mensagem) for mensagem in _dedupe_mensagens(mensagens)]
            return ComandoFechamento(
                os=contexto.get("os"),
                decisao=DECISAO_RETORNAR,
                ocorrencias=ocorrencias,
                metadados={"codigo": dados_conference.get("codigo"), "fechamentoId": contexto.get("fechamentoId")},
            )

        if contexto.get("curadorAprovado") or status_consolidacao == CONSOLIDACAO_APROVADA:
            valor_mo = _valor_mo_orcamento(contexto) or dados_conference.get("valor_servicos") or financeiro.get("valor_servicos") or 0
            ocorrencias_redis = _filtrar_ocorrencias_contexto(
                contexto,
                self._buscar_ocorrencias_passo3(contexto),
            )
            ocorrencias, obs = _ocorrencias_aprovacao(contexto, valor_mo, ocorrencias_redis)
            return ComandoFechamento(
                os=contexto.get("os"),
                decisao=DECISAO_APROVAR,
                valor_aprovado=valor_mo,
                ocorrencias=ocorrencias,
                metadados={
                    "codigo": dados_conference.get("codigo"),
                    "obs": obs,
                    "curadorAprovado": True,
                    "fechamentoId": contexto.get("fechamentoId"),
                },
            )

        if _status_reprovado_automatico(status_consolidacao):
            ocorrencias_contexto = _filtrar_ocorrencias_contexto(
                contexto,
                self._buscar_ocorrencias_passo3(contexto),
            )
            mensagens = _mensagens_redis(ocorrencias_contexto)
            if not mensagens:
                mensagens = [_comentario_reprovacao_automatica(status_consolidacao)]
            ocorrencias = [OcorrenciaFechamento(comentario=mensagem) for mensagem in _dedupe_mensagens(mensagens)]
            return ComandoFechamento(
                os=contexto.get("os"),
                decisao=DECISAO_RETORNAR,
                ocorrencias=ocorrencias,
                metadados={"codigo": dados_conference.get("codigo"), "fechamentoId": contexto.get("fechamentoId")},
            )

        if acao == "RETORNAR_OFICINA":
            ocorrencias_redis = _filtrar_ocorrencias_contexto(
                contexto,
                self._buscar_ocorrencias_passo3(contexto),
            )
            mensagens = _mensagens_redis(ocorrencias_redis)
            if not mensagens:
                mensagens = ["OS retornada por regra operacional."]
            ocorrencias = [OcorrenciaFechamento(comentario=mensagem) for mensagem in _dedupe_mensagens(mensagens)]
            return ComandoFechamento(
                os=contexto.get("os"),
                decisao=DECISAO_RETORNAR,
                ocorrencias=ocorrencias,
                metadados={"codigo": dados_conference.get("codigo"), "fechamentoId": contexto.get("fechamentoId")},
            )

        return ComandoFechamento(
            os=contexto.get("os"),
            decisao=DECISAO_MANUAL,
            ocorrencias=_ocorrencias_manual(
                _filtrar_ocorrencias_contexto(
                    contexto,
                    self._buscar_ocorrencias_passo3(contexto),
                )
            ),
            metadados={"codigo": dados_conference.get("codigo"), "fechamentoId": contexto.get("fechamentoId")},
        )

    def _buscar_ocorrencias_redis(self, os_number: str) -> list[dict]:
        if not self.cache or not hasattr(self.cache, "buscar_ocorrencias_passo3"):
            return []
        return self.cache.buscar_ocorrencias_passo3(os_number)

    def _buscar_ocorrencias_passo3(self, contexto: dict) -> list[dict]:
        ocorrencias = self._buscar_ocorrencias_redis(contexto.get("os"))
        if ocorrencias:
            return ocorrencias
        return ((contexto.get("dadosExtraidos") or {}).get("ocorrencias_passo3") or [])


def _codigo_conference(comando: ComandoFechamento) -> str:
    codigo = (comando.metadados or {}).get("codigo") or comando.os
    if not codigo:
        raise RuntimeError("Codigo Conference nao encontrado para fechamento.")
    return str(codigo)


def _valor_mo_orcamento(contexto: dict):
    validacoes = contexto.get("validacoes") or {}
    orcamento_validacao = validacoes.get("orcamento") or {}
    orcamento = (orcamento_validacao.get("dados") or {}).get("orcamento") or {}
    return orcamento.get("valor_servicos")


def _ocorrencias_aprovacao(
    contexto: dict,
    valor_mo,
    ocorrencias_redis: list[dict] | None = None,
) -> tuple[list[OcorrenciaFechamento], str]:
    dados_conference = contexto.get("dadosConference") or {}
    dados_extraidos = contexto.get("dadosExtraidos") or {}
    validacoes = contexto.get("validacoes") or {}
    seguradora = dados_conference.get("seguradora") or contexto.get("seguradora") or "seguradora"
    orcamento_validacao = validacoes.get("orcamento") or {}
    orcamento = (orcamento_validacao.get("dados") or {}).get("orcamento") or (
        dados_extraidos.get("orcamento") or {}
    )
    data_orcamento = orcamento.get("data_orcamento") or "data nao informada"
    obs = _obs_autorizacao(valor_mo, data_orcamento, seguradora)

    mensagens = _mensagens_redis(ocorrencias_redis)
    mensagens.extend(
        [
            "OS validada automaticamente. Autorizada emissão de nota.",
            obs,
        ]
    )

    return [OcorrenciaFechamento(comentario=mensagem) for mensagem in _dedupe_mensagens(mensagens)], obs


def _ocorrencias_manual(ocorrencias_redis: list[dict] | None = None) -> list[OcorrenciaFechamento]:
    mensagens = _mensagens_redis(ocorrencias_redis)
    mensagens.append("OS marcada para fechamento manual.")
    return [OcorrenciaFechamento(comentario=mensagem) for mensagem in _dedupe_mensagens(mensagens)]


def _mensagens_redis(ocorrencias_redis: list[dict] | None = None) -> list[str]:
    return [item.get("comentario") for item in (ocorrencias_redis or []) if item.get("comentario")]


def _status_reprovado_automatico(status: str | None) -> bool:
    status = str(status or "")
    return status.startswith("REPROVADA") or status.startswith("FALHA") or status.startswith("ERRO")


def _comentario_reprovacao_automatica(status: str | None) -> str:
    mensagens = {
        CONSOLIDACAO_REPROVADA_FALTA_ANEXO: "OS reprovada automaticamente por falta de anexos obrigatórios. Favor revisar e anexar os documentos pendentes.",
        CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO: "OS reprovada automaticamente por divergência ou invalidez de CNPJ. Favor ajustar o faturamento.",
        CONSOLIDACAO_REPROVADA_TERMO_INVALIDO: "OS reprovada automaticamente por inconsistência no termo de quitação. Favor corrigir o documento.",
        CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE: "OS reprovada automaticamente por divergência de valores. Favor revisar orçamento e dados financeiros.",
    }
    return mensagens.get(status, "OS reprovada automaticamente pela validação do RPA. Favor revisar.")


def _filtrar_ocorrencias_contexto(contexto: dict, ocorrencias: list[dict] | None = None) -> list[dict]:
    return _filtrar_ocorrencias_desativadas(ocorrencias or [])


def _filtrar_ocorrencias_desativadas(ocorrencias: list[dict]) -> list[dict]:
    return [item for item in ocorrencias if item.get("id") not in OCORRENCIAS_DESATIVADAS]


def _dedupe_mensagens(mensagens: list[str]) -> list[str]:
    vistos = set()
    deduped = []
    for mensagem in mensagens:
        if mensagem in vistos:
            continue
        vistos.add(mensagem)
        deduped.append(mensagem)
    return deduped


def _obs_autorizacao(valor_mo, data_orcamento: str, seguradora: str) -> str:
    return (
        f"Processo conferido. Faturamento liberado no valor de {_format_money_br(valor_mo)} "
        f"conforme orçamento final autorizado pela cia em {data_orcamento} e consulta efetuada no portal {seguradora}."
    )


def _format_money_br(value) -> str:
    try:
        number = float(value or 0)
    except (TypeError, ValueError):
        number = 0.0
    formatted = f"{number:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return f"R$ {formatted}"


def _comentario_principal(comando: ComandoFechamento, fallback: str) -> str:
    if comando.ocorrencias:
        return comando.ocorrencias[-1].comentario
    return fallback


def _validar_dados_autorizacao_nf(obs: str, valor_bruto_mo) -> None:
    if not str(obs or "").strip():
        raise RuntimeError("Observacao da autorizacao de NF nao foi montada.")
    try:
        valor = float(valor_bruto_mo or 0)
    except (TypeError, ValueError):
        valor = 0.0
    if valor <= 0:
        raise RuntimeError("Valor bruto de M.O. da autorizacao de NF nao foi encontrado.")


def _format_decimal(value) -> str:
    try:
        number = float(value or 0)
    except (TypeError, ValueError):
        number = 0.0
    return f"{number:.2f}"


def _validar_retorno_conference(response: dict, acao: str) -> None:
    if str((response or {}).get("codigo")) == "1":
        return
    mensagem = (response or {}).get("mensagem") or "Sem mensagem de erro."
    raise RuntimeError(f"{acao} falhou: {mensagem}")


def _trace(message: str, *args) -> None:
    text = message % args if args else message
    print(text, flush=True)
    logger.info(message, *args)


def _mensagem_erro_fechamento(comando: ComandoFechamento, exc: Exception) -> str:
    mensagem = str(exc)
    if "cadastrar_ocorrencia_sinistros" in mensagem:
        return f"Erro ao registrar ocorrencia no Conference: {mensagem}."
    if comando.decisao == DECISAO_APROVAR:
        return f"Erro ao autorizar emissão de nota no Conference: {mensagem}."
    if comando.decisao == DECISAO_RETORNAR:
        return f"Erro ao reiniciar reparo no Conference: {mensagem}."
    return mensagem


def _hoje() -> str:
    return datetime.now().strftime("%d/%m/%Y")
