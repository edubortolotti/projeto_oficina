from core.models import DadosConference, ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_PENDENTE


def validar_dados_conference_basicos(dados: DadosConference) -> ValidacaoResultado:
    faltantes = []
    for campo in (
        "codigo",
        "empresa",
        "seguradora_codigo",
        "cnpj_seguradora",
        "seguradora",
        "data",
        "status",
    ):
        if not getattr(dados, campo):
            faltantes.append(campo)

    if not dados.chassi and not dados.placa:
        faltantes.append("chassi_ou_placa")

    valores_invalidos = []
    for campo in ("valor_pecas", "valor_servicos", "valor_franquia"):
        valor = getattr(dados, campo)
        if valor is None or valor < 0:
            valores_invalidos.append(campo)

    observacoes = []
    if dados.status and str(dados.status) != "5":
        observacoes.append(f"status retornado diferente de 5: {dados.status}")

    if faltantes or valores_invalidos or observacoes:
        return ValidacaoResultado(
            item="dados_conference",
            status=STATUS_PENDENTE,
            mensagem="Dados basicos do Conference precisam de complemento ou revisao.",
            dados={
                "faltantes": faltantes,
                "valores_invalidos": valores_invalidos,
                "observacoes": observacoes,
            },
        )

    return ValidacaoResultado(
        item="dados_conference",
        status=STATUS_APROVADO,
        mensagem="Dados basicos do Conference disponiveis para consolidacao.",
        dados={
            "codigo": dados.codigo,
            "empresa": dados.empresa,
            "seguradora": dados.seguradora,
            "status": dados.status,
        },
    )
