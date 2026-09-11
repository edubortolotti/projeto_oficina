from typing import Any, Dict, Optional

from core.models import DadosConference, ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_PENDENTE, STATUS_REPROVADO


ALLIANZ_CNPJS = {
    "61573796000166",
    "61573796003343",
    "61573796004315",
    "61573796012172",
}


def validar_cnpj(
    dados: DadosConference,
    repository=None,
    dados_orcamento: Optional[Dict[str, Any]] = None,
    dados_faturamento: Optional[Dict[str, Any]] = None,
) -> ValidacaoResultado:
    cnpj_empresa = _somente_numeros(dados.cnpj_empresa)
    cnpj_seguradora = _somente_numeros(dados.cnpj_seguradora)

    if _eh_allianz(dados):
        return validar_cnpj_allianz_por_anexo(dados, dados_faturamento)

    if _eh_bradesco(dados):
        return validar_cnpj_bradesco_por_orcamento(dados, dados_orcamento)

    if repository and hasattr(repository, "validar_cnpj_faturamento"):
        return repository.validar_cnpj_faturamento(
            empresa_codigo=dados.empresa,
            seguradora_codigo=dados.seguradora_codigo,
            seguradora_nome=dados.seguradora,
            cnpj_empresa=cnpj_empresa,
            cnpj_seguradora=cnpj_seguradora,
        )

    if not cnpj_empresa or not cnpj_seguradora:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem="CNPJ da empresa ou da seguradora nao foi retornado pela API.",
            dados={
                "cnpj_empresa": dados.cnpj_empresa,
                "cnpj_seguradora": dados.cnpj_seguradora,
            },
        )

    if not _cnpj_valido(cnpj_empresa) or not _cnpj_valido(cnpj_seguradora):
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_REPROVADO,
            mensagem="CNPJ da empresa ou da seguradora possui formato invalido.",
            dados={
                "cnpj_empresa": cnpj_empresa,
                "cnpj_seguradora": cnpj_seguradora,
            },
        )

    regra_seguradora = _validar_regra_seguradora(dados.seguradora, cnpj_empresa, cnpj_seguradora)
    if regra_seguradora is False:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_REPROVADO,
            mensagem="CNPJ da seguradora nao confere com a regra de faturamento conhecida.",
            dados={
                "cnpj_empresa": cnpj_empresa,
                "cnpj_seguradora": cnpj_seguradora,
            },
        )

    if regra_seguradora is None:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem="CNPJ possui formato valido, mas nao ha regra cadastrada para a seguradora.",
            dados={
                "cnpj_empresa": cnpj_empresa,
                "cnpj_seguradora": cnpj_seguradora,
            },
        )

    return ValidacaoResultado(
        item="cnpj",
        status=STATUS_APROVADO,
        mensagem="CNPJ validado conforme regra conhecida.",
        dados={
            "cnpj_empresa": cnpj_empresa,
            "cnpj_seguradora": cnpj_seguradora,
        },
    )


def validar_cnpj_allianz_por_anexo(
    dados: DadosConference,
    dados_faturamento: Optional[Dict[str, Any]],
) -> ValidacaoResultado:
    cnpj_conference = _somente_numeros(dados.cnpj_seguradora)
    dados_extraidos = (dados_faturamento or {}).get("dadosFaturamento") or {}
    cnpj_documento = _somente_numeros(dados_extraidos.get("cnpj"))
    dados_validacao = {
        "regra": "ALLIANZ_DADOS_PARA_FATURAMENTO",
        "cnpj_conference": cnpj_conference,
        "cnpj_documento": cnpj_documento,
        "cnpj_correto": cnpj_documento,
        "dados_faturamento": dados_extraidos,
    }

    if not cnpj_conference:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem="CNPJ da seguradora nao foi retornado pela Conference.",
            dados=dados_validacao,
        )

    if not cnpj_documento:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem='CNPJ nao foi extraido do anexo Allianz "Dados para Faturamento".',
            dados=dados_validacao,
        )

    if cnpj_conference != cnpj_documento:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_REPROVADO,
            mensagem='CNPJ da Conference diverge do CNPJ no anexo Allianz "Dados para Faturamento".',
            dados=dados_validacao,
        )

    return ValidacaoResultado(
        item="cnpj",
        status=STATUS_APROVADO,
        mensagem='CNPJ Allianz confere com o anexo "Dados para Faturamento".',
        dados=dados_validacao,
    )


def validar_cnpj_bradesco_por_orcamento(
    dados: DadosConference,
    dados_orcamento: Optional[Dict[str, Any]],
) -> ValidacaoResultado:
    cnpj_conference = _normalizar_cnpj(dados.cnpj_seguradora)
    cnpj_orcamento = _normalizar_cnpj(
        ((dados_orcamento or {}).get("dadosFaturamento") or {}).get("cnpj")
    )

    if not cnpj_conference:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem="CNPJ da seguradora nao foi retornado pela Conference.",
            dados={
                "regra": "BRADESCO_DADOS_FATURAMENTO_ORCAMENTO",
                "cnpj_conference": cnpj_conference,
                "cnpj_orcamento": cnpj_orcamento,
            },
        )

    if not cnpj_orcamento:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_PENDENTE,
            mensagem="CNPJ de faturamento nao foi encontrado no orcamento Bradesco.",
            dados={
                "regra": "BRADESCO_DADOS_FATURAMENTO_ORCAMENTO",
                "cnpj_conference": cnpj_conference,
                "dados_faturamento": (dados_orcamento or {}).get("dadosFaturamento") or {},
            },
        )

    if cnpj_conference != cnpj_orcamento:
        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_REPROVADO,
            mensagem="CNPJ da Conference diverge do CNPJ em Dados para Faturamento do orcamento.",
            dados={
                "regra": "BRADESCO_DADOS_FATURAMENTO_ORCAMENTO",
                "cnpj_conference": cnpj_conference,
                "cnpj_orcamento": cnpj_orcamento,
                "dados_faturamento": (dados_orcamento or {}).get("dadosFaturamento") or {},
            },
        )

    return ValidacaoResultado(
        item="cnpj",
        status=STATUS_APROVADO,
        mensagem="CNPJ Bradesco validado pelos Dados para Faturamento do orcamento.",
        dados={
            "regra": "BRADESCO_DADOS_FATURAMENTO_ORCAMENTO",
            "cnpj_conference": cnpj_conference,
            "cnpj_orcamento": cnpj_orcamento,
            "dados_faturamento": (dados_orcamento or {}).get("dadosFaturamento") or {},
        },
    )


def _validar_regra_seguradora(seguradora: str, cnpj_empresa: str, cnpj_seguradora: str):
    from modules.seguradora.cnpjs import verifica_cnpj

    if not seguradora:
        return None

    return verifica_cnpj(cnpj_empresa, cnpj_seguradora, seguradora.strip())


def _eh_bradesco(dados: DadosConference) -> bool:
    seguradora = (dados.seguradora or "").strip().lower()
    return seguradora == "bradesco" or str(dados.seguradora_codigo or "") == "4"


def _eh_allianz(dados: DadosConference) -> bool:
    seguradora = (dados.seguradora or "").strip().lower()
    return (
        "allianz" in seguradora
        or "allanz" in seguradora
        or _somente_numeros(dados.cnpj_seguradora) in ALLIANZ_CNPJS
    )


def _somente_numeros(valor):
    if valor is None:
        return None
    return "".join(ch for ch in str(valor) if ch.isdigit())


def _normalizar_cnpj(valor):
    cnpj = _somente_numeros(valor)
    if not cnpj:
        return None
    if len(cnpj) < 14:
        cnpj = cnpj.zfill(14)
    return cnpj


def _cnpj_valido(cnpj: str) -> bool:
    if len(cnpj) != 14 or len(set(cnpj)) == 1:
        return False

    pesos_primeiro = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2]
    pesos_segundo = [6] + pesos_primeiro

    primeiro = _digito(cnpj[:12], pesos_primeiro)
    segundo = _digito(cnpj[:12] + str(primeiro), pesos_segundo)

    return cnpj[-2:] == f"{primeiro}{segundo}"


def _digito(base: str, pesos) -> int:
    soma = sum(int(numero) * peso for numero, peso in zip(base, pesos))
    resto = soma % 11
    return 0 if resto < 2 else 11 - resto
