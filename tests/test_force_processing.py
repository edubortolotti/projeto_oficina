import unittest
from types import SimpleNamespace
from unittest.mock import MagicMock, patch

from client import forcar_processamento_os
from core.models import DadosConference
from core.status import STATUS_APROVADO, STATUS_PENDENTE
from services.validacoes.orcamento import validar_orcamento


def _orcamento():
    return {
        "orcamento": [
            {
                "deducoes": {"franquia_bruta": 10.0},
                "totais": {
                    "faturar": {
                        "servicos": 100.0,
                        "pecas": 60.0,
                        "total": 150.0,
                    }
                },
            }
        ]
    }


class ForceProcessingTest(unittest.TestCase):
    def test_validacao_pode_ignorar_complemento_somente_quando_solicitado(self):
        conference = DadosConference(
            os="123",
            seguradora="Porto",
            valor_total=150.0,
            valor_franquia=10.0,
            complemento=True,
            raw={"complemento": True},
        )

        bloqueado = validar_orcamento("/tmp/orcamento.pdf", conference, _orcamento())
        forcado = validar_orcamento(
            "/tmp/orcamento.pdf",
            conference,
            _orcamento(),
            ignorar_complemento_manual=True,
        )

        self.assertEqual(STATUS_PENDENTE, bloqueado.status)
        self.assertEqual(STATUS_APROVADO, forcado.status)

    @patch("client._passo3_fechamento")
    @patch("client._mysql_repository")
    @patch("client._passo1_triagem")
    def test_orquestrador_executa_tres_passos_quando_passo2_enfileira(
        self,
        passo1_factory,
        repository_factory,
        passo3_factory,
    ):
        resultado_passo1 = SimpleNamespace(
            to_dict=lambda: {"os": "123", "status_consolidacao": "APROVADA_CONSOLIDACAO"}
        )
        passo1_factory.return_value.executar_codigo.return_value = resultado_passo1
        repository_factory.return_value.executar_passo2_curadoria_automatica.return_value = {
            "ok": True,
            "total": 1,
            "resultados": [{"os": "123", "acao": "APROVAR"}],
        }
        passo3_factory.return_value.executar_os.return_value = {"ok": True, "os": "123"}

        resultado = forcar_processamento_os("123")

        self.assertTrue(resultado["ok"])
        passo1_factory.return_value.executar_codigo.assert_called_once_with(
            codigo="123",
            forcar=True,
            reler_orcamento=True,
            reler_documentos=True,
            ignorar_complemento_manual=True,
            forcar_releitura=True,
        )
        repository_factory.return_value.executar_passo2_curadoria_automatica.assert_called_once_with(
            limit=1,
            dry_run=False,
            responsavel="rpa_forcado",
            os_number="123",
        )
        passo3_factory.return_value.executar_os.assert_called_once_with("123", dry_run=False)

    @patch("client._passo3_fechamento")
    @patch("client._mysql_repository")
    @patch("client._passo1_triagem")
    def test_orquestrador_nao_executa_passo3_sem_fila(
        self,
        passo1_factory,
        repository_factory,
        passo3_factory,
    ):
        passo1_factory.return_value.executar_codigo.return_value = SimpleNamespace(
            to_dict=lambda: {"os": "123", "status_consolidacao": "PENDENTE_BATIMENTO_HUMANO"}
        )
        repository_factory.return_value.executar_passo2_curadoria_automatica.return_value = {
            "ok": True,
            "total": 0,
            "resultados": [],
        }

        resultado = forcar_processamento_os("123")

        self.assertTrue(resultado["passo3"]["ignorado"])
        passo3_factory.assert_not_called()


if __name__ == "__main__":
    unittest.main()
