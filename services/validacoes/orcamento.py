from typing import Any, Dict, Optional

from core.models import DadosConference, ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_PENDENTE, STATUS_REPROVADO


ALLIANZ_CNPJS = {
    "61573796000166",
    "61573796003343",
    "61573796004315",
    "61573796012172",
}


def validar_orcamento(
    arquivo: Optional[str],
    dados_conference: DadosConference,
    dados_gemini: Optional[Dict[str, Any]],
    tolerancia: float = 0.01,
    ignorar_complemento_manual: bool = False,
) -> ValidacaoResultado:
    complemento = _indicador_complemento(dados_conference)
    if complemento["manual"] and not ignorar_complemento_manual:
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_PENDENTE,
            mensagem="OS com complemento no Conference exige verificacao manual.",
            dados={
                "complemento": complemento,
                "conference": dados_conference.raw,
            },
        )

    if not arquivo:
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_REPROVADO,
            mensagem="Orcamento final nao foi encontrado.",
        )

    if not dados_gemini:
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_PENDENTE,
            mensagem="Orcamento encontrado, mas nao foi possivel extrair dados com IA.",
            dados={"arquivo": arquivo},
        )

    if _eh_allianz(dados_conference) and not _vistoria_autorizada_final(dados_gemini):
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_REPROVADO,
            mensagem='Orcamento Allianz sem a tarja "Vistoria Autorizada Final".',
            dados={
                "arquivo": arquivo,
                "vistoria_autorizada_final": False,
                "dados_extraidos": dados_gemini.get("dados") or {},
            },
        )

    valores_orcamento = _extrair_valores_orcamento(dados_gemini, dados_conference)
    comparacoes = _comparar_valores(dados_conference, valores_orcamento, tolerancia)

    if not comparacoes:
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_PENDENTE,
            mensagem="Valores do Conference ou do orcamento estao incompletos para batimento.",
            dados={"orcamento": valores_orcamento, "conference": dados_conference.raw},
        )

    divergentes = [item for item in comparacoes if not item["confere"]]
    if divergentes:
        return ValidacaoResultado(
            item="orcamento",
            status=STATUS_REPROVADO,
            mensagem="Divergencia entre valores do Conference e orcamento anexado.",
            dados={"comparacoes": comparacoes, "orcamento": valores_orcamento},
        )

    return ValidacaoResultado(
        item="orcamento",
        status=STATUS_APROVADO,
        mensagem="Valores do Conference conferem com o orcamento anexado.",
        dados={"comparacoes": comparacoes, "orcamento": valores_orcamento},
    )


def _eh_allianz(dados_conference: DadosConference) -> bool:
    seguradora = (dados_conference.seguradora or "").strip().lower()
    cnpj = "".join(
        char for char in str(dados_conference.cnpj_seguradora or "") if char.isdigit()
    )
    return "allianz" in seguradora or "allanz" in seguradora or cnpj in ALLIANZ_CNPJS


def _vistoria_autorizada_final(dados_gemini: Dict[str, Any]) -> bool:
    valor = (dados_gemini.get("dados") or {}).get("vistoriaAutorizadaFinal")
    if isinstance(valor, bool):
        return valor
    return str(valor or "").strip().lower() in {"1", "sim", "true", "yes"}


def _extrair_valores_orcamento(
    dados_gemini: Dict[str, Any],
    dados_conference: DadosConference | None = None,
) -> Dict[str, Optional[float]]:
    if _eh_sompo_resumo_geral_extraido(dados_gemini):
        return {
            "valor_servicos": _to_float(dados_gemini.get("total_mo")),
            "valor_pecas": _to_float(dados_gemini.get("total_pecas")),
            "valor_total": _to_float(dados_gemini.get("total_geral")),
            "valor_franquia": _abs_or_none(_to_float(dados_gemini.get("total_franquia"))),
            "valor_total_extraido": _to_float(dados_gemini.get("total_geral")),
            "valor_franquia_extraido": _abs_or_none(_to_float(dados_gemini.get("total_franquia"))),
            "valor_franquia_totalizador": None,
            "valor_franquia_calculado": None,
            "modelo_mo": "SOMPO_RESUMO_GERAL",
            "sinistro": None,
            "data_orcamento": None,
            "dados_faturamento": {},
        }

    primeiro_orcamento = _orcamento_base(dados_gemini, dados_conference)

    totais = primeiro_orcamento.get("totais", {})
    faturar = totais.get("faturar", {})
    deducoes = primeiro_orcamento.get("deducoes", {})
    modelo_mo = "LIQUIDO_MAO_DE_OBRA" if _usa_liquido_mao_obra(dados_conference) else "FATURAR_SERVICOS"
    valor_servicos = _valor_servicos_orcamento(totais, faturar, modelo_mo)
    valor_pecas = _to_float(faturar.get("pecas"))
    valor_total_extraido = _to_float(faturar.get("total"))
    valor_franquia_extraido = _abs_or_none(_to_float(deducoes.get("franquia_bruta")))
    valor_franquia_totalizador = _abs_or_none(_to_float(deducoes.get("total")))
    valor_franquia_calculado_extraido = _valor_franquia_calculada(
        valor_servicos,
        valor_pecas,
        valor_total_extraido,
    )
    valor_franquia_para_total = _valor_franquia_preferida_conference(
        valor_franquia_extraido,
        valor_franquia_totalizador,
        valor_franquia_calculado_extraido,
        dados_conference,
        fallback_totalizador=True,
    )
    valor_total = _valor_total_orcamento(
        valor_servicos,
        valor_pecas,
        valor_franquia_para_total,
        valor_total_extraido,
    )
    valor_franquia = _valor_franquia_orcamento(
        valor_servicos,
        valor_pecas,
        valor_total,
        valor_franquia_extraido,
        valor_franquia_totalizador,
        valor_franquia_calculado_extraido,
        dados_conference,
    )

    return {
        "valor_servicos": valor_servicos,
        "valor_pecas": valor_pecas,
        "valor_total": valor_total,
        "valor_franquia": valor_franquia,
        "valor_total_extraido": valor_total_extraido,
        "valor_franquia_extraido": valor_franquia_extraido,
        "valor_franquia_totalizador": valor_franquia_totalizador,
        "valor_franquia_calculado": valor_franquia_calculado_extraido,
        "modelo_mo": modelo_mo,
        "sinistro": (dados_gemini.get("dados") or {}).get("sinistro"),
        "data_orcamento": (dados_gemini.get("dados") or {}).get("dataOrcamento"),
        "dados_faturamento": dados_gemini.get("dadosFaturamento") or {},
    }


def _eh_sompo_resumo_geral_extraido(dados: Dict[str, Any]) -> bool:
    return set(dados) == {"total_franquia", "total_pecas", "total_mo", "total_geral"}


def _comparar_valores(
    dados_conference: DadosConference,
    valores_orcamento: Dict[str, Optional[float]],
    tolerancia: float,
):
    comparacoes = []
    campos = [
        "valor_total",
        "valor_franquia",
    ]

    for campo in campos:
        valor_conference = _valor_conference_para_comparacao(dados_conference, valores_orcamento, campo)
        valor_orcamento = valores_orcamento.get(campo)
        if valor_conference is None or valor_orcamento is None:
            continue

        diferenca = round(float(valor_conference) - float(valor_orcamento), 2)
        comparacoes.append(
            {
                "campo": campo,
                "conference": valor_conference,
                "orcamento": valor_orcamento,
                "diferenca": diferenca,
                "confere": abs(diferenca) <= tolerancia,
            }
        )

    return comparacoes


def _orcamento_base(dados_gemini: Dict[str, Any], dados_conference: DadosConference | None = None) -> Dict[str, Any]:
    if _usa_liquido_mao_obra(dados_conference) and dados_gemini.get("liberado"):
        return dados_gemini.get("liberado") or {}

    orcamentos = dados_gemini.get("orcamento") or []
    if orcamentos:
        return orcamentos[0] or {}
    return dados_gemini.get("liberado") or {}


def _valor_conference_para_comparacao(
    dados_conference: DadosConference,
    valores_orcamento: Dict[str, Optional[float]],
    campo: str,
):
    if campo == "valor_servicos":
        return valores_orcamento.get("valor_servicos")
    return getattr(dados_conference, campo)


def _valor_servicos_orcamento(totais: Dict[str, Any], faturar: Dict[str, Any], modelo_mo: str) -> Optional[float]:
    if modelo_mo == "FATURAR_SERVICOS":
        return _to_float(faturar.get("servicos"))
    valor_servicos = _to_float(totais.get("liquido_mao_obra"))
    if valor_servicos is not None:
        return valor_servicos
    return _to_float(faturar.get("servicos"))


def _valor_total_orcamento(
    valor_servicos: Optional[float],
    valor_pecas: Optional[float],
    valor_franquia: Optional[float],
    valor_total_extraido: Optional[float],
) -> Optional[float]:
    if valor_servicos is not None and valor_pecas is not None and valor_franquia is not None:
        return round(float(valor_servicos) + float(valor_pecas) - float(valor_franquia), 2)
    return valor_total_extraido


def _valor_franquia_orcamento(
    valor_servicos: Optional[float],
    valor_pecas: Optional[float],
    valor_total: Optional[float],
    valor_franquia_extraido: Optional[float],
    valor_franquia_totalizador: Optional[float] = None,
    valor_franquia_calculado_extraido: Optional[float] = None,
    dados_conference: DadosConference | None = None,
) -> Optional[float]:
    franquia_preferida = _valor_franquia_preferida_conference(
        valor_franquia_extraido,
        valor_franquia_totalizador,
        valor_franquia_calculado_extraido,
        dados_conference,
        fallback_totalizador=False,
    )
    if franquia_preferida is not None:
        return franquia_preferida

    valor_franquia_calculado = _valor_franquia_calculada(valor_servicos, valor_pecas, valor_total)

    valor_conference = getattr(dados_conference, "valor_franquia", None) if dados_conference else None
    if _valores_conferem(valor_conference, valor_franquia_calculado):
        return valor_franquia_calculado
    if _valores_conferem(valor_conference, valor_franquia_extraido):
        return valor_franquia_extraido

    if valor_franquia_calculado is not None:
        return valor_franquia_calculado
    return valor_franquia_extraido


def _valor_franquia_preferida_conference(
    valor_franquia_extraido: Optional[float],
    valor_franquia_totalizador: Optional[float],
    valor_franquia_calculado: Optional[float] = None,
    dados_conference: DadosConference | None = None,
    fallback_totalizador: bool = True,
) -> Optional[float]:
    valor_conference = getattr(dados_conference, "valor_franquia", None) if dados_conference else None
    if _valores_conferem(valor_conference, valor_franquia_extraido):
        return valor_franquia_extraido
    if _valores_conferem(valor_conference, valor_franquia_totalizador):
        return valor_franquia_totalizador
    if _valores_conferem(valor_conference, valor_franquia_calculado):
        return valor_franquia_calculado
    if not fallback_totalizador:
        return None
    if valor_franquia_totalizador is not None:
        return valor_franquia_totalizador
    return valor_franquia_extraido


def _valor_franquia_calculada(
    valor_servicos: Optional[float],
    valor_pecas: Optional[float],
    valor_total: Optional[float],
) -> Optional[float]:
    if valor_servicos is None or valor_pecas is None or valor_total is None:
        return None
    return round(float(valor_servicos) + float(valor_pecas) - float(valor_total), 2)


def _valores_conferem(valor_a, valor_b, tolerancia: float = 0.01) -> bool:
    if valor_a is None or valor_b is None:
        return False
    return abs(round(float(valor_a) - float(valor_b), 2)) <= tolerancia


def _usa_liquido_mao_obra(dados_conference: DadosConference | None) -> bool:
    seguradora = _normalizar_seguradora(getattr(dados_conference, "seguradora", "") or "")
    modelo_atual = {"mapfre", "azul", "porto", "itau"}
    return seguradora not in modelo_atual


def _normalizar_seguradora(valor: str) -> str:
    normalized = (
        valor.strip()
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
    return "_".join(normalized.split())


def _abs_or_none(value):
    if value is None:
        return None
    return abs(value)


def _to_float(value):
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


def _indicador_complemento(dados_conference: DadosConference) -> Dict[str, Any]:
    raw = dados_conference.raw or {}
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

    valor = dados_conference.complemento
    return {
        "manual": _valor_indica_sim(valor),
        "campo": "complemento",
        "valor": valor,
    }


def _valor_indica_sim(value: Any) -> bool:
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
