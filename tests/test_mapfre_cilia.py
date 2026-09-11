import unittest
from unittest.mock import patch

from core.models import DadosConference, ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_PENDENTE, STATUS_REPROVADO
from ia.orcamento_models import modelo_orcamento
from services.ia.document_reader import GeminiDocumentReader, OpenAIDocumentReader
from services.validacoes.orcamento import validar_orcamento
from steps.passo_1_consolidacao.executar import Passo1Consolidacao
from steps.passo_1_consolidacao.triagem import _deve_tentar_modelo_mapfre_atual


def _orcamento(total, servicos=None, pecas=0.0, franquia=0.0, dados_faturamento=None):
    servicos = total if servicos is None else servicos
    return {
        "dados": {"dataOrcamento": "06/08/2026"},
        "dadosFaturamento": dados_faturamento or {},
        "orcamento": [
            {
                "deducoes": {
                    "franquia_bruta": franquia,
                    "total": franquia,
                },
                "totais": {
                    "faturar": {
                        "servicos": servicos,
                        "pecas": pecas,
                        "total": total,
                    }
                },
            }
        ],
    }


class _ConferenceMapfre:
    def buscar_dados_os(self, os_number):
        return DadosConference(
            os=os_number,
            seguradora="Mapfre",
            valor_total=960.0,
            valor_franquia=0.0,
        )

    def download_documento(self, _os_number, tipo):
        if tipo == "orcamento_final":
            return "/tmp/mapfre-cilia.pdf"
        return None


class _ReaderDoisModelos:
    def __init__(self, total_fallback=960.0):
        self.chamadas = []
        self.total_fallback = total_fallback

    def ler_orcamento(self, arquivo, seguradora=None, perfil=None):
        self.chamadas.append((arquivo, seguradora, perfil))
        if perfil == "mapfre_atual":
            return _orcamento(self.total_fallback)
        return _orcamento(100.0)

    def ler_termo_quitacao(self, _arquivo):
        return None

    def ler_dados_faturamento(self, _arquivo):
        return None


class _Repository:
    def contar_execucoes_status(self, _os_number, _status):
        return 0


class MapfreCiliaTest(unittest.TestCase):
    def setUp(self):
        self.mapfre = DadosConference(
            os="123",
            seguradora="Mapfre Seguros",
            valor_total=960.0,
            valor_franquia=0.0,
        )

    def test_mapfre_cilia_e_o_perfil_principal(self):
        modelo = modelo_orcamento("Mapfre Seguros")

        self.assertEqual("mapfre_cilia", modelo["key"])
        self.assertIn("valores vigentes", modelo["prompt"])
        self.assertIn("Ignore valores antigos riscados", modelo["prompt"])
        self.assertIn("Dados para Faturamento", modelo["prompt"])
        self.assertIn("Valor Fipe", modelo["prompt"])

    def test_modelo_mapfre_anterior_continua_disponivel_como_fallback(self):
        modelo = modelo_orcamento("Mapfre Seguros", perfil="mapfre_atual")

        self.assertEqual("mapfre_atual", modelo["key"])
        self.assertIn("modelo atual", modelo["prompt"])
        self.assertIn("deixe dadosFaturamento vazio", modelo["prompt"])

    def test_valores_do_pdf_cilia_conferem_com_conference(self):
        extraido = _orcamento(
            total=960.0,
            servicos=960.0,
            pecas=0.0,
            franquia=0.0,
            dados_faturamento={
                "nome": "MAPFRE SEGUROS GERAIS S.A.",
                "cnpj": "61.074.175/0001-38",
            },
        )

        resultado = validar_orcamento("/tmp/mapfre-cilia.pdf", self.mapfre, extraido)

        self.assertEqual(STATUS_APROVADO, resultado.status)
        self.assertEqual(960.0, resultado.dados["orcamento"]["valor_servicos"])
        self.assertEqual(0.0, resultado.dados["orcamento"]["valor_pecas"])
        self.assertEqual(0.0, resultado.dados["orcamento"]["valor_franquia"])

    def test_fallback_so_e_acionado_para_mapfre_reprovada_ou_incompleta(self):
        for status in (STATUS_REPROVADO, STATUS_PENDENTE):
            with self.subTest(status=status):
                self.assertTrue(
                    _deve_tentar_modelo_mapfre_atual(
                        self.mapfre,
                        "/tmp/mapfre.pdf",
                        ValidacaoResultado("orcamento", status, "teste"),
                        orcamento_lido_nesta_execucao=True,
                        tem_ajuste_manual=False,
                    )
                )

        self.assertFalse(
            _deve_tentar_modelo_mapfre_atual(
                self.mapfre,
                "/tmp/mapfre.pdf",
                ValidacaoResultado("orcamento", STATUS_APROVADO, "teste"),
                orcamento_lido_nesta_execucao=True,
                tem_ajuste_manual=False,
            )
        )

    def test_fluxo_legado_tenta_cilia_e_depois_modelo_atual(self):
        reader = _ReaderDoisModelos()
        passo = Passo1Consolidacao(_ConferenceMapfre(), reader, _Repository())

        resultado = passo.executar_os("123")

        self.assertEqual(STATUS_APROVADO, resultado.validacoes["orcamento"].status)
        self.assertEqual(
            [
                ("/tmp/mapfre-cilia.pdf", "Mapfre", None),
                ("/tmp/mapfre-cilia.pdf", "Mapfre", "mapfre_atual"),
            ],
            reader.chamadas,
        )
        self.assertEqual(
            ["mapfre_cilia", "mapfre_atual"],
            [
                tentativa["perfil"]
                for tentativa in resultado.dados_extraidos["tentativas_modelos_orcamento"]
            ],
        )
        self.assertEqual(
            STATUS_REPROVADO,
            resultado.dados_extraidos["tentativas_modelos_orcamento"][0]["status"],
        )
        self.assertEqual(
            STATUS_APROVADO,
            resultado.dados_extraidos["tentativas_modelos_orcamento"][1]["status"],
        )

    def test_fluxo_reprova_quando_os_dois_modelos_divergem(self):
        reader = _ReaderDoisModelos(total_fallback=200.0)
        passo = Passo1Consolidacao(_ConferenceMapfre(), reader, _Repository())

        resultado = passo.executar_os("123")

        self.assertEqual(STATUS_REPROVADO, resultado.validacoes["orcamento"].status)
        self.assertEqual(
            [STATUS_REPROVADO, STATUS_REPROVADO],
            [
                tentativa["status"]
                for tentativa in resultado.dados_extraidos["tentativas_modelos_orcamento"]
            ],
        )

    @patch("ia.gemini.generate", return_value={"origem": "gemini"})
    def test_gemini_recebe_o_perfil_de_fallback(self, generate):
        resultado = GeminiDocumentReader().ler_orcamento(
            "/tmp/mapfre.pdf",
            seguradora="Mapfre",
            perfil="mapfre_atual",
        )

        self.assertEqual({"origem": "gemini"}, resultado)
        generate.assert_called_once_with(
            "/tmp/mapfre.pdf",
            seguradora="Mapfre",
            perfil="mapfre_atual",
        )

    @patch("ia.openai_document.generate", return_value={"origem": "openai"})
    def test_openai_recebe_o_perfil_de_fallback(self, generate):
        resultado = OpenAIDocumentReader().ler_orcamento(
            "/tmp/mapfre.pdf",
            seguradora="Mapfre",
            perfil="mapfre_atual",
        )

        self.assertEqual({"origem": "openai"}, resultado)
        generate.assert_called_once_with(
            "/tmp/mapfre.pdf",
            seguradora="Mapfre",
            perfil="mapfre_atual",
        )


if __name__ == "__main__":
    unittest.main()
