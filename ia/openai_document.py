import base64
import json
import logging
import os
import time
from random import uniform

from openai import APIStatusError, OpenAI, RateLimitError

from ia.orcamento_models import modelo_orcamento


logger = logging.getLogger(__name__)

DEFAULT_OPENAI_DOCUMENT_MODEL = "gpt-5.4-mini"
DEFAULT_OPENAI_RETRY_ATTEMPTS = 4
DEFAULT_OPENAI_RETRY_BASE_SECONDS = 3.0
DEFAULT_OPENAI_RETRY_MAX_SECONDS = 30.0

DADOS_FATURAMENTO_PROMPT = """Leia o documento ou e-mail "Dados para Faturamento" da Allianz.
Extraia exclusivamente os dados da Allianz indicados para emissao da nota fiscal.
O campo dadosFaturamento.cnpj deve conter o CNPJ informado no corpo do documento,
mesmo que esteja pontuado. Nao use CNPJ de remetente, destinatario, oficina ou assinatura.
Responda apenas JSON no schema solicitado."""

DADOS_FATURAMENTO_SCHEMA = {
    "type": "object",
    "properties": {
        "dadosFaturamento": {
            "type": "object",
            "properties": {
                "razaoSocial": {"type": "string"},
                "cnpj": {"type": "string"},
                "endereco": {"type": "string"},
                "cep": {"type": "string"},
                "cidadeEstado": {"type": "string"},
                "inscricaoMunicipal": {"type": "string"},
                "inscricaoEstadual": {"type": "string"},
            },
        },
    },
}

ORCAMENTO_PROMPT = """Por favor, preciso coletar dados importantes do arquivo anexado como sinistro, apolice, chassis, licença, valor do serviço, valor peças, totais.

Quando existir a seção "Dados para Faturamento", extraia os dados dessa seção no objeto dadosFaturamento. O CNPJ de faturamento deve ser o CNPJ que aparece junto ao nome/unidade dessa seção, por exemplo "RIBEIRAO PRETO - 92.682.038/0110-63".

Quando existir o label "Líquido de Mão de Obra" ou "Liquido de Mao de Obra", extraia esse valor em totais.liquido_mao_obra. Esse campo é especialmente importante para modelos de orçamento Yelum, Tokio e Bradesco.

Na seção "DEDUÇÕES", diferencie "Franquia Bruta" do totalizador final da dedução/franquia. Para Porto, Itaú e Azul, o valor efetivo de franquia é o totalizador final exibido abaixo da seção/imagem de deduções, por exemplo "-( 2.906,00 )", e deve ser extraído em deducoes.total. O campo deducoes.franquia_bruta deve manter apenas o valor do label "Franquia Bruta", por exemplo 3.306,00."""

TERMO_QUITACAO_PROMPT = (
    "Preciso que responda com SIM ou NAO se o documento foi assinado no campo "
    "Segurado/Terceiro e qual o nome da seguradora que consta no documento."
)

ORCAMENTO_SCHEMA = {
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

TERMO_QUITACAO_SCHEMA = {
    "type": "object",
    "properties": {
        "dados": {
            "type": "object",
            "properties": {
                "assinaturaSegurado": {"type": "string"},
                "seguradora": {"type": "string"},
            },
        }
    },
}


def generate(arquivo: str, seguradora: str | None = None, perfil: str | None = None):
    modelo = modelo_orcamento(seguradora, arquivo=arquivo, perfil=perfil)
    return _extrair_documento(
        arquivo,
        modelo["prompt"],
        modelo["schema"],
        modelo["nome_schema"],
    )


def verificar_tq(documento: str):
    return _extrair_documento(
        documento,
        TERMO_QUITACAO_PROMPT,
        TERMO_QUITACAO_SCHEMA,
        "termo_quitacao",
    )


def extrair_dados_faturamento(arquivo: str):
    return _extrair_documento(
        arquivo,
        DADOS_FATURAMENTO_PROMPT,
        DADOS_FATURAMENTO_SCHEMA,
        "dados_faturamento_allianz",
    )


def _extrair_documento(arquivo: str, prompt: str, schema: dict, nome_schema: str):
    client = _openai_client()
    response = _responses_create_with_retry(
        client,
        arquivo,
        prompt,
        schema,
        nome_schema,
    )
    return _parse_json_response(_response_text(response), nome_schema)


def _openai_client():
    return OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def _openai_model_name():
    return os.getenv("OPENAI_DOCUMENT_MODEL", DEFAULT_OPENAI_DOCUMENT_MODEL)


def _responses_create_with_retry(client, arquivo: str, prompt: str, schema: dict, nome_schema: str):
    attempts = max(1, _int_env("OPENAI_RETRY_ATTEMPTS", DEFAULT_OPENAI_RETRY_ATTEMPTS))
    base_seconds = max(0.1, _float_env("OPENAI_RETRY_BASE_SECONDS", DEFAULT_OPENAI_RETRY_BASE_SECONDS))
    max_seconds = max(base_seconds, _float_env("OPENAI_RETRY_MAX_SECONDS", DEFAULT_OPENAI_RETRY_MAX_SECONDS))

    for tentativa in range(1, attempts + 1):
        try:
            return client.responses.create(
                model=_openai_model_name(),
                input=[
                    {
                        "role": "user",
                        "content": [
                            _input_file(arquivo),
                            {"type": "input_text", "text": prompt},
                        ],
                    }
                ],
                text={
                    "format": {
                        "type": "json_schema",
                        "name": nome_schema,
                        "schema": schema,
                        "strict": False,
                    }
                },
                temperature=_float_env("OPENAI_DOCUMENT_TEMPERATURE", 0.0),
                max_output_tokens=_int_env("OPENAI_DOCUMENT_MAX_OUTPUT_TOKENS", 8192),
            )
        except Exception as exc:
            if not _is_rate_limit(exc):
                raise

            if tentativa >= attempts:
                mensagem = (
                    f"OpenAI sem quota/rate limit em {nome_schema}: "
                    f"tentativa={tentativa}/{attempts} erro={exc}"
                )
                print(mensagem, flush=True)
                logger.error(mensagem)
                raise

            espera = min(max_seconds, base_seconds * (2 ** (tentativa - 1))) + uniform(0, 1)
            mensagem = (
                f"OpenAI 429/rate limit em {nome_schema}; "
                f"tentativa={tentativa}/{attempts}; aguardando={espera:.1f}s"
            )
            print(mensagem, flush=True)
            logger.warning(mensagem)
            time.sleep(espera)


def _input_file(arquivo: str):
    with open(arquivo, "rb") as file:
        encoded = base64.b64encode(file.read()).decode("utf-8")
    return {
        "type": "input_file",
        "filename": os.path.basename(arquivo),
        "file_data": f"data:application/pdf;base64,{encoded}",
    }


def _response_text(response) -> str:
    output_text = getattr(response, "output_text", None)
    if output_text:
        return output_text

    output = getattr(response, "output", None) or []
    for item in output:
        for content in getattr(item, "content", []) or []:
            text = getattr(content, "text", None)
            if text:
                return text
    raise ValueError("OpenAI nao retornou texto na resposta")


def _parse_json_response(json_result: str, origem: str):
    try:
        return json.loads(json_result)
    except json.JSONDecodeError as exc:
        inicio = max(0, exc.pos - 250)
        fim = min(len(json_result), exc.pos + 250)
        trecho = json_result[inicio:fim]
        mensagem = (
            f"OpenAI retornou JSON invalido em {origem}: "
            f"linha={exc.lineno} coluna={exc.colno} posicao={exc.pos} "
            f"tamanho={len(json_result)} trecho={trecho!r}"
        )
        print(mensagem, flush=True)
        logger.error(mensagem)
        raise


def _is_rate_limit(exc: Exception) -> bool:
    if isinstance(exc, RateLimitError):
        return True
    if isinstance(exc, APIStatusError) and exc.status_code == 429:
        return True
    status_code = getattr(exc, "status_code", None) or getattr(exc, "code", None)
    if status_code == 429:
        return True
    mensagem = str(exc)
    return "429" in mensagem or "rate limit" in mensagem.lower()


def _int_env(nome: str, padrao: int) -> int:
    try:
        return int(os.getenv(nome, padrao))
    except (TypeError, ValueError):
        return padrao


def _float_env(nome: str, padrao: float) -> float:
    try:
        return float(os.getenv(nome, padrao))
    except (TypeError, ValueError):
        return padrao
