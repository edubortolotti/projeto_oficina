import unittest
from unittest.mock import MagicMock, patch

from core.models import DadosConference
from core.status import STATUS_APROVADO
from ia.orcamento_models import modelo_orcamento
from services.validacoes.orcamento import validar_orcamento


class SompoResumoGeralTest(unittest.TestCase):
    @patch("ia.orcamento_models._eh_sompo_resumo_geral", return_value=True)
    def test_reconhece_pdf_sompo_resumo_geral(self, _detector):
        modelo = modelo_orcamento("Sompo", arquivo="/tmp/sompo.pdf")

        self.assertEqual("sompo_resumo_geral", modelo["key"])
        self.assertEqual(
            {"total_franquia", "total_pecas", "total_mo", "total_geral"},
            set(modelo["schema"]["properties"]),
        )
        self.assertFalse(modelo["schema"]["additionalProperties"])
        self.assertIn('Nao extraia "Valor Bruto das Pecas" nem "Descontos"', modelo["prompt"])

    def test_sompo_sem_arquivo_mantem_fallback_cilia(self):
        modelo = modelo_orcamento("Sompo")

        self.assertEqual("outros", modelo["key"])

    @patch("ia.orcamento_models.PdfReader")
    def test_detector_exige_todos_os_labels_do_resumo(self, pdf_reader):
        pagina = MagicMock()
        pagina.extract_text.return_value = """
            Resumo Geral
            Valor Bruto das Peças 17.852,90
            Descontos 1.785,30
            Deduções 0,00
            Total Peças 16.067,60
            Mão de Obra Total 4.500,00
            Total Regulado 20.567,60
        """
        pdf_reader.return_value.pages = [pagina]

        modelo = modelo_orcamento("Sompo", arquivo="/tmp/sompo.pdf")

        self.assertEqual("sompo_resumo_geral", modelo["key"])

    def test_valida_quatro_totais_sem_recalcular(self):
        conference = DadosConference(
            os="123",
            seguradora="Sompo",
            valor_total=20567.60,
            valor_franquia=0.0,
        )
        extraido = {
            "total_franquia": 0.0,
            "total_pecas": 16067.60,
            "total_mo": 4500.0,
            "total_geral": 20567.60,
        }

        resultado = validar_orcamento("/tmp/sompo.pdf", conference, extraido)

        self.assertEqual(STATUS_APROVADO, resultado.status)
        self.assertEqual("SOMPO_RESUMO_GERAL", resultado.dados["orcamento"]["modelo_mo"])
        self.assertEqual(16067.60, resultado.dados["orcamento"]["valor_pecas"])
        self.assertEqual(4500.0, resultado.dados["orcamento"]["valor_servicos"])
        self.assertEqual(20567.60, resultado.dados["orcamento"]["valor_total"])


if __name__ == "__main__":
    unittest.main()
