import unittest

from core.models import DadosConference
from core.status import STATUS_APROVADO, STATUS_REPROVADO
from ia.orcamento_models import modelo_orcamento
from integrations.conference.client import _encontrar_anexo
from repositories.mysql_consolidacao_repository import MySqlConsolidacaoRepository
from services.validacoes.cnpj import validar_cnpj
from services.validacoes.orcamento import validar_orcamento
from steps.passo_1_consolidacao.triagem import _tipos_anexos_obrigatorios
from steps.passo_3_fechamento.executar import DECISAO_APROVAR, Passo3Fechamento


def _orcamento(vistoria_autorizada_final=None):
    dados = {"dataOrcamento": "10/04/2026"}
    if vistoria_autorizada_final is not None:
        dados["vistoriaAutorizadaFinal"] = vistoria_autorizada_final
    return {
        "dados": dados,
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
        ],
    }


class _CursorPasso2:
    def __init__(self, rows):
        self.rows = rows

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False

    def execute(self, _query, _params=()):
        return None

    def fetchall(self):
        return self.rows


class _ConexaoPasso2:
    def __init__(self, rows):
        self.cursor_instance = _CursorPasso2(rows)
        self.rollback_called = False

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        return False

    def cursor(self, dictionary=False):
        return self.cursor_instance

    def rollback(self):
        self.rollback_called = True


class AllianzRulesTest(unittest.TestCase):
    def setUp(self):
        self.allianz = DadosConference(
            os="123",
            seguradora="Allianz Seguros",
            cnpj_empresa="00.384.141/0001-55",
            cnpj_seguradora="61.573.796/0135-78",
            valor_total=150.0,
            valor_franquia=10.0,
            placa="ABC1D23",
        )

    def test_modelo_allianz_exige_tarja(self):
        modelo = modelo_orcamento("Allianz Seguros")

        self.assertEqual("allianz", modelo["key"])
        self.assertIn("Vistoria Autorizada Final", modelo["prompt"])
        self.assertIn(
            "vistoriaAutorizadaFinal",
            modelo["schema"]["properties"]["dados"]["properties"],
        )

    def test_orcamento_allianz_aprova_com_tarja(self):
        resultado = validar_orcamento(
            "/tmp/orcamento.pdf",
            self.allianz,
            _orcamento(vistoria_autorizada_final=True),
        )

        self.assertEqual(STATUS_APROVADO, resultado.status)

    def test_orcamento_allianz_reprova_sem_tarja(self):
        resultado = validar_orcamento(
            "/tmp/orcamento.pdf",
            self.allianz,
            _orcamento(vistoria_autorizada_final=False),
        )

        self.assertEqual(STATUS_REPROVADO, resultado.status)
        self.assertIn("Vistoria Autorizada Final", resultado.mensagem)

    def test_tarja_nao_e_exigida_de_outra_seguradora(self):
        porto = DadosConference(
            os="456",
            seguradora="Porto",
            valor_total=150.0,
            valor_franquia=10.0,
        )

        resultado = validar_orcamento(
            "/tmp/orcamento.pdf",
            porto,
            _orcamento(),
        )

        self.assertEqual(STATUS_APROVADO, resultado.status)

    def test_cnpj_allianz_compara_apenas_numeros(self):
        resultado = validar_cnpj(
            self.allianz,
            dados_faturamento={
                "dadosFaturamento": {"cnpj": "61.573.796/0135-78"}
            },
        )

        self.assertEqual(STATUS_APROVADO, resultado.status)
        self.assertEqual("61573796013578", resultado.dados["cnpj_documento"])

    def test_cnpj_allianz_reprova_divergencia(self):
        resultado = validar_cnpj(
            self.allianz,
            dados_faturamento={
                "dadosFaturamento": {"cnpj": "61.573.796/0001-66"}
            },
        )

        self.assertEqual(STATUS_REPROVADO, resultado.status)
        self.assertEqual("61573796000166", resultado.dados["cnpj_correto"])

    def test_dados_faturamento_e_anexo_obrigatorio_so_para_allianz(self):
        self.assertIn("dados_faturamento", _tipos_anexos_obrigatorios(self.allianz))
        porto = DadosConference(os="456", seguradora="Porto", placa="ABC1D23")
        self.assertNotIn("dados_faturamento", _tipos_anexos_obrigatorios(porto))

    def test_conference_localiza_tipo_dados_para_faturamento(self):
        anexos = [
            {"codigo": 1, "tipo": "Orçamento Final"},
            {"codigo": 2, "tipo": "Dados para Faturamento"},
        ]

        encontrado = _encontrar_anexo(anexos, "dados_faturamento")

        self.assertEqual(2, encontrado["codigo"])

    def test_passo2_enfileira_allianz_aprovada(self):
        conexao = _ConexaoPasso2(
            [
                {
                    "os": "851649",
                    "seguradora": "Allianz",
                    "statusConsolidacao": "APROVADA_CONSOLIDACAO",
                    "acaoSugerida": "ENVIAR_PARA_FECHAMENTO",
                    "dadosConference": {"codigo": "851649"},
                    "dadosExtraidos": {},
                    "validacoes": {},
                    "retornosOficina": 0,
                }
            ]
        )
        repository = object.__new__(MySqlConsolidacaoRepository)
        repository._connect = lambda: conexao

        resultado = repository.executar_passo2_curadoria_automatica(dry_run=True)

        self.assertEqual("APROVAR", resultado["resultados"][0]["acao"])
        self.assertTrue(conexao.rollback_called)

    def test_passo3_nao_bloqueia_allianz_aprovada(self):
        passo3 = Passo3Fechamento(
            conference_client=object(),
            repository=object(),
        )

        resultado = passo3.executar_contexto(
            {
                "os": "851649",
                "seguradora": "Allianz",
                "statusConsolidacao": "APROVADA_CONSOLIDACAO",
                "acaoSugerida": "ENVIAR_PARA_FECHAMENTO",
                "dadosConference": {
                    "codigo": "851649",
                    "valor_servicos": 5150,
                },
                "dadosExtraidos": {},
            },
            dry_run=True,
        )

        self.assertEqual(DECISAO_APROVAR, resultado["comando"]["decisao"])


if __name__ == "__main__":
    unittest.main()
