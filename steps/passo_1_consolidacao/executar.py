import logging
from typing import List

from core.models import ResultadoConsolidacao, ValidacaoResultado
from core.status import (
    ACAO_ENVIAR_PASSO_2,
    CONSOLIDACAO_ERRO_TECNICO,
    CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
    STATUS_ERRO,
    STATUS_PENDENTE,
    STATUS_REPROVADO,
)
from integrations.conference.client import ConferenceClient
from repositories.consolidacao_repository import ConsolidacaoRepository
from services.ia.document_reader import DocumentReader
from services.validacoes.anexos import validar_anexos
from services.validacoes.classificador import classificar_consolidacao
from services.validacoes.cnpj import validar_cnpj
from services.validacoes.orcamento import validar_orcamento
from services.validacoes.termo_quitacao import validar_termo_quitacao


logger = logging.getLogger(__name__)


class Passo1Consolidacao:
    def __init__(
        self,
        conference_client: ConferenceClient,
        document_reader: DocumentReader,
        repository: ConsolidacaoRepository,
    ):
        self.conference_client = conference_client
        self.document_reader = document_reader
        self.repository = repository

    def executar(self) -> List[ResultadoConsolidacao]:
        resultados = []
        ordens = self.conference_client.listar_os_para_consolidacao()

        for ordem in ordens:
            resultado = self.executar_os(ordem.numero)
            self.repository.salvar(resultado)
            resultados.append(resultado)

        return resultados

    def executar_os(self, os_number: str) -> ResultadoConsolidacao:
        try:
            dados_conference = self.conference_client.buscar_dados_os(os_number)
            downloads = {
                "orcamento_final": self.conference_client.download_documento(
                    os_number,
                    "orcamento_final",
                ),
                "termo_quitacao": None,
            }
            if _eh_allianz(dados_conference):
                downloads["dados_faturamento"] = self.conference_client.download_documento(
                    os_number,
                    "dados_faturamento",
                )

            dados_orcamento = self._ler_orcamento(downloads["orcamento_final"], dados_conference.seguradora)
            validacao_orcamento = validar_orcamento(
                downloads["orcamento_final"],
                dados_conference,
                dados_orcamento,
            )
            tentativas_modelos_orcamento = []
            if _eh_mapfre(dados_conference):
                tentativas_modelos_orcamento.append(
                    _resumo_tentativa_modelo_orcamento("mapfre_cilia", validacao_orcamento)
                )
            if _deve_tentar_modelo_mapfre_atual(
                dados_conference,
                downloads["orcamento_final"],
                validacao_orcamento,
            ):
                dados_orcamento = self._ler_orcamento(
                    downloads["orcamento_final"],
                    dados_conference.seguradora,
                    perfil="mapfre_atual",
                )
                validacao_orcamento = validar_orcamento(
                    downloads["orcamento_final"],
                    dados_conference,
                    dados_orcamento,
                )
                tentativas_modelos_orcamento.append(
                    _resumo_tentativa_modelo_orcamento("mapfre_atual", validacao_orcamento)
                )
            dados_faturamento = self._ler_dados_faturamento(
                downloads.get("dados_faturamento")
            )
            valor_franquia_tq = _valor_franquia_para_tq(dados_orcamento, dados_conference.valor_franquia)
            exige_termo_quitacao = valor_franquia_tq is not None and valor_franquia_tq > 0

            if exige_termo_quitacao:
                downloads["termo_quitacao"] = self.conference_client.download_documento(
                    os_number,
                    "termo_quitacao",
                )

            dados_termo = self._ler_termo_quitacao(downloads["termo_quitacao"])

            validacoes = {
                "anexos": validar_anexos(downloads),
                "cnpj": validar_cnpj(
                    dados_conference,
                    dados_faturamento=dados_faturamento,
                ),
                "termo_quitacao": validar_termo_quitacao(
                    downloads["termo_quitacao"],
                    dados_conference.seguradora,
                    dados_termo,
                    valor_franquia=valor_franquia_tq,
                ),
                "orcamento": validacao_orcamento,
            }

            tentativas_valor_divergente = self._tentativas_valor_divergente(os_number, validacoes)
            status_consolidacao, acao_sugerida = classificar_consolidacao(
                validacoes,
                tentativas_valor_divergente=tentativas_valor_divergente,
            )

            return ResultadoConsolidacao(
                os=os_number,
                seguradora=dados_conference.seguradora,
                status_consolidacao=status_consolidacao,
                acao_sugerida=acao_sugerida,
                validacoes=validacoes,
                dados_conference=dados_conference.raw,
                dados_extraidos={
                    "orcamento": dados_orcamento or {},
                    "termo_quitacao": dados_termo or {},
                    "dados_faturamento": dados_faturamento or {},
                    "tentativas_modelos_orcamento": tentativas_modelos_orcamento,
                    "downloads": downloads,
                },
            )
        except Exception as exc:
            logger.exception("Erro tecnico no Passo 1 ao processar OS %s", os_number)
            erro = str(exc)
            validacoes = {
                "erro_tecnico": ValidacaoResultado(
                    item="erro_tecnico",
                    status=STATUS_ERRO,
                    mensagem=erro,
                )
            }
            return ResultadoConsolidacao(
                os=os_number,
                seguradora="",
                status_consolidacao=CONSOLIDACAO_ERRO_TECNICO,
                acao_sugerida=ACAO_ENVIAR_PASSO_2,
                validacoes=validacoes,
                erros=[erro],
            )

    def _ler_orcamento(self, arquivo, seguradora=None, perfil=None):
        if not arquivo:
            return None
        try:
            return self.document_reader.ler_orcamento(
                arquivo,
                seguradora=seguradora,
                perfil=perfil,
            )
        except Exception:
            return None

    def _tentativas_valor_divergente(self, os_number: str, validacoes: dict) -> int:
        orcamento = validacoes.get("orcamento")
        if not orcamento or orcamento.status != STATUS_REPROVADO:
            return 0
        if not self.repository or not hasattr(self.repository, "contar_execucoes_status"):
            return 1
        return self.repository.contar_execucoes_status(
            os_number,
            CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
        ) + 1

    def _ler_termo_quitacao(self, arquivo):
        if not arquivo:
            return None
        try:
            return self.document_reader.ler_termo_quitacao(arquivo)
        except Exception:
            return None

    def _ler_dados_faturamento(self, arquivo):
        if not arquivo:
            return None
        try:
            return self.document_reader.ler_dados_faturamento(arquivo)
        except Exception:
            return None


def _eh_allianz(dados) -> bool:
    seguradora = (getattr(dados, "seguradora", "") or "").strip().lower()
    cnpj = "".join(
        char
        for char in str(getattr(dados, "cnpj_seguradora", "") or "")
        if char.isdigit()
    )
    return (
        "allianz" in seguradora
        or "allanz" in seguradora
        or cnpj in {
            "61573796000166",
            "61573796003343",
            "61573796004315",
            "61573796012172",
        }
    )


def _eh_mapfre(dados) -> bool:
    return "mapfre" in (getattr(dados, "seguradora", "") or "").strip().lower()


def _deve_tentar_modelo_mapfre_atual(dados, arquivo, validacao: ValidacaoResultado) -> bool:
    complemento = ((validacao.dados or {}).get("complemento") or {}).get("manual")
    return bool(
        _eh_mapfre(dados)
        and arquivo
        and not complemento
        and validacao.status in {STATUS_REPROVADO, STATUS_PENDENTE}
    )


def _resumo_tentativa_modelo_orcamento(perfil: str, validacao: ValidacaoResultado) -> dict:
    dados = validacao.dados or {}
    return {
        "perfil": perfil,
        "status": validacao.status,
        "mensagem": validacao.mensagem,
        "comparacoes": dados.get("comparacoes") or [],
        "orcamento": dados.get("orcamento") or {},
    }


def _valor_franquia_para_tq(dados_orcamento: dict | None, valor_franquia_conference):
    valor_orcamento = _valor_franquia_efetiva_orcamento(dados_orcamento or {}, valor_franquia_conference)
    if valor_orcamento is not None:
        return valor_orcamento
    return valor_franquia_conference


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
