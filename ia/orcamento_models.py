import copy
import unicodedata

from pypdf import PdfReader


BASE_ORCAMENTO_SCHEMA = {
    "type": "object",
    "properties": {
        "dados": {
            "type": "object",
            "properties": {
                "sinistro": {"type": "string"},
                "apolice": {"type": "string"},
                "segurado": {
                    "type": "object",
                    "properties": {
                        "nome": {"type": "string"},
                        "telefone": {"type": "string"},
                    },
                },
                "veiculo": {
                    "type": "object",
                    "properties": {
                        "modelo": {"type": "string"},
                        "chassi": {"type": "string"},
                        "licenca": {"type": "string"},
                        "impregnacao": {"type": "string"},
                        "fabricacao": {"type": "integer"},
                        "modeloAno": {"type": "integer"},
                        "kmAtual": {"type": "integer"},
                    },
                },
                "dataOrcamento": {"type": "string"},
                "vistoriaAutorizadaFinal": {"type": "boolean"},
            },
        },
        "dadosFaturamento": {
            "type": "object",
            "properties": {
                "nome": {"type": "string"},
                "cnpj": {"type": "string"},
                "endereco": {"type": "string"},
            },
        },
        "orcamento": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "id": {"type": "integer"},
                    "deducoes": {
                        "type": "object",
                        "properties": {
                            "franquia_bruta": {"type": "number"},
                            "avaria_previa": {"type": "number"},
                            "total": {"type": "number"},
                        },
                    },
                    "totais": {
                        "type": "object",
                        "properties": {
                            "totalOrcamento": {"type": "number"},
                            "liquido_mao_obra": {"type": "number"},
                            "faturar": {
                                "type": "object",
                                "properties": {
                                    "servicos": {"type": "number"},
                                    "pecas": {"type": "number"},
                                    "total": {"type": "number"},
                                },
                            },
                        },
                    },
                },
            },
        },
        "liberado": {
            "type": "object",
            "properties": {
                "deducoes": {
                    "type": "object",
                    "properties": {
                        "franquia_bruta": {"type": "number"},
                        "avaria_previa": {"type": "number"},
                        "total": {"type": "number"},
                    },
                },
                "totais": {
                    "type": "object",
                    "properties": {
                        "totalOrcamento": {"type": "number"},
                        "liquido_mao_obra": {"type": "number"},
                        "faturar": {
                            "type": "object",
                            "properties": {
                                "servicos": {"type": "number"},
                                "pecas": {"type": "number"},
                                "total": {"type": "number"},
                            },
                        },
                    },
                },
            },
        },
    },
}


COMMON_OUTPUT_RULES = """Responda apenas JSON no schema solicitado.
Converta valores monetarios brasileiros para number, sem simbolo de moeda.
Use valores positivos em deducoes.franquia_bruta, deducoes.total e deducoes.avaria_previa.
Preencha dados.dataOrcamento com a data do orcamento/autorizacao mais relevante do documento."""

SOMPO_RESUMO_GERAL_SCHEMA = {
    "type": "object",
    "properties": {
        "total_franquia": {"type": "number"},
        "total_pecas": {"type": "number"},
        "total_mo": {"type": "number"},
        "total_geral": {"type": "number"},
    },
    "required": ["total_franquia", "total_pecas", "total_mo", "total_geral"],
    "additionalProperties": False,
}

SOMPO_RESUMO_GERAL_PROMPT = """Leia exclusivamente a tabela intitulada "Resumo Geral" do laudo de vistoria Sompo.
Ignore todas as outras areas, tabelas e informacoes do documento.

Extraia somente estes quatro valores da tabela "Resumo Geral":
- "Deducoes" em total_franquia.
- "Total Pecas" em total_pecas.
- "Mao de Obra Total" em total_mo.
- "Total Regulado" em total_geral.

Nao extraia "Valor Bruto das Pecas" nem "Descontos".
Nao calcule, some, subtraia ou deduza valores. Copie o valor exibido em cada label indicado.
Converta valores monetarios brasileiros para number, sem simbolo de moeda.
Responda somente com total_franquia, total_pecas, total_mo e total_geral no schema solicitado."""

PROMPTS = {
    "mapfre_cilia": f"""Leia o orcamento Mapfre no modelo CILIA.

Use exclusivamente os valores vigentes, normalmente destacados em laranja. Ignore valores antigos riscados.
Na secao TOTAL DO ORCAMENTO:
- Extraia "Liquido de Mao de Obra" em totais.faturar.servicos.
- Some "Liquido de Pecas (Oficina)" e "Liquido de Pecas (Seguradora)" e extraia o resultado em totais.faturar.pecas.
- Extraia "Total Geral" em totais.faturar.total.
Nao confunda "Valor Segurado" ou "Valor Fipe" com franquia.
Quando nao existir franquia/deducao explicitamente identificada, use 0 em deducoes.franquia_bruta e deducoes.total.
Quando existir "Dados para Faturamento" ao final do documento, extraia nome, CNPJ e endereco em dadosFaturamento.
Extraia tambem os dados gerais, veiculo, sinistro, apolice e a data mais recente da autorizacao/orcamento.

{COMMON_OUTPUT_RULES}""",
    "mapfre_atual": f"""Leia o orcamento Mapfre no modelo atual, que nao utiliza o resumo visual do CILIA.

Extraia dados gerais, veiculo, sinistro, apolice, data do orcamento e valores financeiros.
Use totais.faturar.servicos para o valor de servicos/mao de obra a faturar.
Use totais.faturar.pecas para o valor de pecas.
Use totais.faturar.total para o total liquido a faturar.
Use deducoes.franquia_bruta para a franquia exibida no orcamento.
Nao extraia Dados para Faturamento; deixe dadosFaturamento vazio.

{COMMON_OUTPUT_RULES}""",
    "porto_azul_itau": f"""Leia o orcamento Porto, Azul ou Itau.

Extraia dados gerais, veiculo, sinistro, apolice, data do orcamento e valores financeiros.
Use totais.faturar.servicos para o valor de servicos/mao de obra a faturar.
Use totais.faturar.pecas para o valor de pecas.
Use totais.faturar.total para o total liquido a faturar.
Na secao DEDUCOES, diferencie Franquia Bruta do totalizador final da deducao/franquia.
O valor efetivo da franquia e o totalizador final exibido abaixo da secao/imagem de deducoes, por exemplo "-( 2.906,00 )"; extraia em deducoes.total.
O campo deducoes.franquia_bruta deve manter apenas o valor do label Franquia Bruta.
Nao extraia Dados para Faturamento; deixe dadosFaturamento vazio.

{COMMON_OUTPUT_RULES}""",
    "hdi": f"""Leia o orcamento HDI/CILIA.

Extraia dados gerais, dados do cliente, veiculo, oficina, sinistro, orcamento e a maior data do documento como dados.dataOrcamento.
Na secao RESUMO ORCAMENTO, extraia:
- "Servicos (Servicos adicionais + Mao de obra)" em totais.liquido_mao_obra.
- "Pecas Oficina" em totais.faturar.pecas.
- "Total Orcamento" em totais.faturar.total.
Na secao A FATURAR CLIENTE, extraia:
- "Franquia" em deducoes.franquia_bruta e deducoes.total.
- "Avarias" em deducoes.avaria_previa.
Na secao A FATURAR HDI, nao use "NF Servico" como mao de obra quando existir "Servicos (Servicos adicionais + Mao de obra)" no RESUMO ORCAMENTO.
Nao extraia Dados para Faturamento; deixe dadosFaturamento vazio.

{COMMON_OUTPUT_RULES}""",
    "bradesco": f"""Leia o orcamento Bradesco/CILIA.

Extraia dados gerais, dados do cliente, veiculo, oficina, sinistro, orcamento e data do documento.
Quando existir a secao Dados para Faturamento, extraia esses dados em dadosFaturamento.
O CNPJ de faturamento deve ser o CNPJ que aparece junto ao nome/unidade dessa secao, por exemplo "RIBEIRAO PRETO - 92.682.038/0110-63".
Extraia "Liquido de Mao de Obra" ou "Líquido de Mão de Obra" em totais.liquido_mao_obra.
Extraia pecas em totais.faturar.pecas, total liquido/faturar em totais.faturar.total e franquia em deducoes.franquia_bruta.

{COMMON_OUTPUT_RULES}""",
    "allianz": f"""Leia o orcamento Allianz/CILIA.

Extraia dados gerais, dados do cliente, veiculo, oficina, sinistro, orcamento e data do documento.
Verifique visualmente se existe a tarja diagonal roxa com o texto "Vistoria Autorizada Final",
normalmente no canto superior direito. Preencha dados.vistoriaAutorizadaFinal com true somente
quando essa tarja estiver presente e legivel; caso contrario, use false.
Nao extraia Dados para Faturamento deste orcamento; deixe dadosFaturamento vazio.
Extraia mao de obra/servicos em totais.faturar.servicos, pecas em totais.faturar.pecas,
total liquido/faturar em totais.faturar.total e franquia em deducoes.franquia_bruta.

{COMMON_OUTPUT_RULES}""",
    "outros": f"""Leia o orcamento CILIA.

Extraia dados gerais, dados do cliente, veiculo, oficina, sinistro, orcamento e data do documento.
Nao extraia Dados para Faturamento; deixe dadosFaturamento vazio.
Extraia "Liquido de Mao de Obra" ou "Líquido de Mão de Obra" em totais.liquido_mao_obra.
Extraia pecas em totais.faturar.pecas, total liquido/faturar em totais.faturar.total e franquia em deducoes.franquia_bruta.

{COMMON_OUTPUT_RULES}""",
}


def modelo_orcamento(
    seguradora: str | None = None,
    arquivo: str | None = None,
    perfil: str | None = None,
) -> dict:
    if _eh_sompo(seguradora) and arquivo and _eh_sompo_resumo_geral(arquivo):
        return {
            "key": "sompo_resumo_geral",
            "nome_schema": "orcamento_sompo_resumo_geral",
            "prompt": SOMPO_RESUMO_GERAL_PROMPT,
            "schema": copy.deepcopy(SOMPO_RESUMO_GERAL_SCHEMA),
        }

    key = perfil or _modelo_key(seguradora)
    if key not in PROMPTS:
        raise ValueError(f"Perfil de orcamento invalido: {key}")
    return {
        "key": key,
        "nome_schema": f"orcamento_{key}",
        "prompt": PROMPTS[key],
        "schema": copy.deepcopy(BASE_ORCAMENTO_SCHEMA),
    }


def _modelo_key(seguradora: str | None) -> str:
    nome = _normalizar(seguradora)
    if "mapfre" in nome:
        return "mapfre_cilia"
    if any(item in nome for item in ("porto", "azul", "itau")):
        return "porto_azul_itau"
    if "hdi" in nome:
        return "hdi"
    if "bradesco" in nome:
        return "bradesco"
    if "allianz" in nome or "allanz" in nome:
        return "allianz"
    return "outros"


def _normalizar(valor: str | None) -> str:
    texto = unicodedata.normalize("NFKD", str(valor or ""))
    texto = "".join(char for char in texto if not unicodedata.combining(char))
    return texto.strip().lower()


def _eh_sompo(seguradora: str | None) -> bool:
    return "sompo" in _normalizar(seguradora)


def _eh_sompo_resumo_geral(arquivo: str) -> bool:
    try:
        texto = "\n".join((pagina.extract_text() or "") for pagina in PdfReader(arquivo).pages)
    except Exception:
        return False

    texto = _normalizar(texto)
    labels_obrigatorios = (
        "resumo geral",
        "valor bruto das pecas",
        "descontos",
        "deducoes",
        "total pecas",
        "mao de obra total",
        "total regulado",
    )
    return all(label in texto for label in labels_obrigatorios)
