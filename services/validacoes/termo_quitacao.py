from typing import Any, Dict, Optional

from core.models import ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_ERRO, STATUS_PENDENTE, STATUS_REPROVADO


def validar_termo_quitacao(
    arquivo: Optional[str],
    seguradora_os: str,
    dados_gemini: Optional[Dict[str, Any]],
    valor_franquia: Optional[float] = None,
) -> ValidacaoResultado:
    valor_franquia = _normalizar_valor_franquia(valor_franquia)
    if valor_franquia is None:
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_PENDENTE,
            mensagem="Valor de franquia ausente; nao foi possivel determinar se TQ e exigido.",
        )

    if valor_franquia is not None and valor_franquia < 0:
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_ERRO,
            mensagem="Valor de franquia negativo; regra de TQ inconsistente.",
            dados={"valor_franquia": valor_franquia},
        )

    if valor_franquia == 0:
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_APROVADO,
            mensagem="Termo de quitacao dispensado: valor de franquia igual a zero.",
            dados={"valor_franquia": valor_franquia, "dispensado": True},
        )

    if not arquivo:
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_REPROVADO,
            mensagem="Termo de quitacao nao foi encontrado.",
        )

    if not dados_gemini:
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_PENDENTE,
            mensagem="Termo de quitacao encontrado, mas nao foi possivel extrair dados com IA.",
            dados={"arquivo": arquivo},
        )

    dados = dados_gemini.get("dados", {})
    seguradora_documento = (dados.get("seguradora") or "").strip()
    assinatura = (dados.get("assinaturaSegurado") or "").strip().upper()

    if assinatura != "SIM":
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_REPROVADO,
            mensagem="Termo de quitacao sem assinatura do segurado ou terceiro.",
            dados=dados_gemini,
        )

    if _normalizar(seguradora_documento) != _normalizar(seguradora_os):
        return ValidacaoResultado(
            item="termo_quitacao",
            status=STATUS_REPROVADO,
            mensagem="Seguradora do termo de quitacao nao confere com a OS.",
            dados=dados_gemini,
        )

    return ValidacaoResultado(
        item="termo_quitacao",
        status=STATUS_APROVADO,
        mensagem="Termo de quitacao assinado e seguradora confere.",
        dados=dados_gemini,
    )


def _normalizar(valor: str) -> str:
    return " ".join(valor.lower().split())


def _normalizar_valor_franquia(valor) -> Optional[float]:
    if valor in (None, ""):
        return None
    try:
        return float(valor)
    except (TypeError, ValueError):
        return None
