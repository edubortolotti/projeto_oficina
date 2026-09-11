import unittest

from core.models import ValidacaoResultado
from core.status import (
    ACAO_ENVIAR_PASSO_2,
    ACAO_FECHAR_MANUAL,
    CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
    CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE,
    STATUS_APROVADO,
    STATUS_REPROVADO,
)
from services.validacoes.classificador import classificar_consolidacao
from steps.passo_1_consolidacao.triagem import _ocorrencias_operacionais


def _validacoes_com_orcamento_reprovado():
    return {
        "anexos": ValidacaoResultado("anexos", STATUS_APROVADO, "ok"),
        "cnpj": ValidacaoResultado("cnpj", STATUS_APROVADO, "ok"),
        "termo_quitacao": ValidacaoResultado("termo_quitacao", STATUS_APROVADO, "ok"),
        "orcamento": ValidacaoResultado("orcamento", STATUS_REPROVADO, "divergente"),
    }


class TentativasValorDivergenteTest(unittest.TestCase):
    def test_primeira_e_segunda_reprovacoes_seguem_passo2(self):
        for tentativa in (1, 2):
            with self.subTest(tentativa=tentativa):
                status, acao = classificar_consolidacao(
                    _validacoes_com_orcamento_reprovado(),
                    tentativas_valor_divergente=tentativa,
                )
                self.assertEqual(CONSOLIDACAO_REPROVADA_VALOR_DIVERGENTE, status)
                self.assertEqual(ACAO_ENVIAR_PASSO_2, acao)

    def test_terceira_reprovacao_e_seguintes_vao_para_manual(self):
        for tentativa in (3, 4, 10):
            with self.subTest(tentativa=tentativa):
                status, acao = classificar_consolidacao(
                    _validacoes_com_orcamento_reprovado(),
                    tentativas_valor_divergente=tentativa,
                )
                self.assertEqual(CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL, status)
                self.assertEqual(ACAO_FECHAR_MANUAL, acao)

    def test_ocorrencia_manual_informa_reincidencia(self):
        ocorrencias = _ocorrencias_operacionais(
            status_consolidacao=CONSOLIDACAO_PENDENTE_COMPLEMENTO_MANUAL,
            acao_sugerida=ACAO_FECHAR_MANUAL,
            tentativas_valor_divergente=3,
        )

        self.assertEqual("reincidencia_valor", ocorrencias[0]["origem"])
        self.assertIn("3 verificações", ocorrencias[0]["comentario"])


if __name__ == "__main__":
    unittest.main()
