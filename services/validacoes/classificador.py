from typing import Dict

from core.models import ValidacaoResultado
from core.status import (
    ACAO_ENVIAR_PASSO_2,
    ACAO_ENVIAR_PASSO_3,
    ACAO_FECHAR_MANUAL,
    ACAO_RETORNAR_OFICINA,
    CONSOLIDACAO_APROVADA,
    CONSOLIDACAO_ERRO_TECNICO,
    CONSOLIDACAO_PENDENTE_BATIMENTO,
    CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
    CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO,
    CONSOLIDACAO_REPROVADA_FALTA_ANEXO,
    CONSOLIDACAO_REPROVADA_TERMO_INVALIDO,
    CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
    STATUS_APROVADO,
    STATUS_ERRO,
    STATUS_PENDENTE,
    STATUS_REPROVADO,
)


LIMITE_TENTATIVAS_VALOR_DIVERGENTE = 3


def classificar_consolidacao(
    validacoes: Dict[str, ValidacaoResultado],
    tentativas_valor_divergente: int = 0,
):
    anexos = validacoes.get("anexos")
    cnpj = validacoes.get("cnpj")
    termo = validacoes.get("termo_quitacao")
    orcamento = validacoes.get("orcamento")

    if (
        orcamento
        and orcamento.status == STATUS_PENDENTE
        and ((orcamento.dados or {}).get("complemento") or {}).get("manual")
    ):
        return CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL, ACAO_FECHAR_MANUAL

    if any(validacao.status == STATUS_ERRO for validacao in validacoes.values()):
        return CONSOLIDACAO_ERRO_TECNICO, ACAO_ENVIAR_PASSO_2

    if anexos and anexos.status == STATUS_REPROVADO:
        return CONSOLIDACAO_REPROVADA_FALTA_ANEXO, ACAO_RETORNAR_OFICINA

    if cnpj and cnpj.status == STATUS_REPROVADO:
        return CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO, ACAO_FECHAR_MANUAL

    if termo and termo.status == STATUS_REPROVADO:
        return CONSOLIDACAO_REPROVADA_TERMO_INVALIDO, ACAO_RETORNAR_OFICINA

    if (
        orcamento
        and orcamento.status == STATUS_REPROVADO
        and tentativas_valor_divergente >= LIMITE_TENTATIVAS_VALOR_DIVERGENTE
    ):
        return CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL, ACAO_FECHAR_MANUAL

    if orcamento and orcamento.status == STATUS_REPROVADO:
        return CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE, ACAO_ENVIAR_PASSO_2

    if any(validacao.status == STATUS_PENDENTE for validacao in validacoes.values()):
        return CONSOLIDACAO_PENDENTE_BATIMENTO, ACAO_RETORNAR_OFICINA

    if all(validacao.status == STATUS_APROVADO for validacao in validacoes.values()):
        return CONSOLIDACAO_APROVADA, ACAO_ENVIAR_PASSO_3

    return CONSOLIDACAO_PENDENTE_BATIMENTO, ACAO_RETORNAR_OFICINA
