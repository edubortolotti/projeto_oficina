import base64
import glob
import logging
import os
import time
from random import uniform
from google import genai
from google.genai import types
from google.oauth2 import service_account
import json

from ia.orcamento_models import modelo_orcamento


logger = logging.getLogger(__name__)

DEFAULT_GEMINI_MODEL = "gemini-2.5-flash"
DEFAULT_VERTEX_AI_PROJECT = "zamba-cb2ab"
DEFAULT_VERTEX_AI_LOCATION = "us-central1"
DEFAULT_VERTEX_AI_KEY_PATTERNS = (
    "/keys/zampa*.json",
    "/keys/zamba*.json",
    "keys/zampa*.json",
    "keys/zamba*.json",
)
VERTEX_AI_SCOPES = ("https://www.googleapis.com/auth/cloud-platform",)
DEFAULT_GEMINI_RETRY_ATTEMPTS = 4
DEFAULT_GEMINI_RETRY_BASE_SECONDS = 3.0
DEFAULT_GEMINI_RETRY_MAX_SECONDS = 30.0

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


def _gemini_client():
    credentials = _load_credentials()
    return genai.Client(
        vertexai=True,
        project=os.getenv("VERTEX_AI_PROJECT") or _project_from_credentials(credentials) or DEFAULT_VERTEX_AI_PROJECT,
        location=os.getenv("VERTEX_AI_LOCATION", DEFAULT_VERTEX_AI_LOCATION),
        credentials=credentials,
    )


def _gemini_model_name():
    return os.getenv("GEMINI_MODEL", DEFAULT_GEMINI_MODEL)


def _load_credentials():
    key_path = _vertex_ai_key_path()
    if not key_path:
        return None
    return service_account.Credentials.from_service_account_file(
        key_path,
        scopes=VERTEX_AI_SCOPES,
    )


def _vertex_ai_key_path():
    configured = os.getenv("VERTEX_AI_CREDENTIALS") or os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    if configured:
        return configured

    for pattern in DEFAULT_VERTEX_AI_KEY_PATTERNS:
        matches = sorted(glob.glob(pattern))
        if matches:
            return matches[0]

    return None


def _project_from_credentials(credentials):
    if not credentials:
        return None
    return getattr(credentials, "project_id", None)


def _parse_json_response(json_result, origem: str):
    if not isinstance(json_result, str):
        return json_result

    try:
        return json.loads(json_result)
    except json.JSONDecodeError as exc:
        inicio = max(0, exc.pos - 250)
        fim = min(len(json_result), exc.pos + 250)
        trecho = json_result[inicio:fim]
        mensagem = (
            f"Gemini retornou JSON invalido em {origem}: "
            f"linha={exc.lineno} coluna={exc.colno} posicao={exc.pos} "
            f"tamanho={len(json_result)} trecho={trecho!r}"
        )
        print(mensagem, flush=True)
        logger.error(mensagem)
        raise


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


def _normalizar_schema_genai(schema):
    if isinstance(schema, dict):
        normalizado = {}
        for chave, valor in schema.items():
            chave_normalizada = "type" if chave == "type_" else chave
            if chave_normalizada == "type" and isinstance(valor, str):
                normalizado[chave_normalizada] = valor.upper()
            else:
                normalizado[chave_normalizada] = _normalizar_schema_genai(valor)
        return normalizado
    if isinstance(schema, list):
        return [_normalizar_schema_genai(item) for item in schema]
    return schema


def _is_quota_exhausted(exc: Exception) -> bool:
    status_code = getattr(exc, "status_code", None) or getattr(exc, "code", None)
    if status_code == 429:
        return True
    mensagem = str(exc)
    return "RESOURCE_EXHAUSTED" in mensagem or "Resource exhausted" in mensagem or "429" in mensagem


def _generate_content_with_retry(client, contents, generation_config, safety_settings, origem: str):
    attempts = max(1, _int_env("GEMINI_RETRY_ATTEMPTS", DEFAULT_GEMINI_RETRY_ATTEMPTS))
    base_seconds = max(0.1, _float_env("GEMINI_RETRY_BASE_SECONDS", DEFAULT_GEMINI_RETRY_BASE_SECONDS))
    max_seconds = max(base_seconds, _float_env("GEMINI_RETRY_MAX_SECONDS", DEFAULT_GEMINI_RETRY_MAX_SECONDS))

    for tentativa in range(1, attempts + 1):
        try:
            config = types.GenerateContentConfig(
                max_output_tokens=generation_config.get("max_output_tokens"),
                temperature=generation_config.get("temperature"),
                top_p=generation_config.get("top_p"),
                response_mime_type=generation_config.get("response_mime_type"),
                response_schema=_normalizar_schema_genai(generation_config.get("response_schema")),
                safety_settings=safety_settings,
            )
            return client.models.generate_content(
                model=_gemini_model_name(),
                contents=contents,
                config=config,
            )
        except Exception as exc:
            if not _is_quota_exhausted(exc):
                raise

            if tentativa >= attempts:
                mensagem = (
                    f"Gemini sem quota/rate limit em {origem}: "
                    f"tentativa={tentativa}/{attempts} erro={exc}"
                )
                print(mensagem, flush=True)
                logger.error(mensagem)
                raise

            espera = min(max_seconds, base_seconds * (2 ** (tentativa - 1))) + uniform(0, 1)
            mensagem = (
                f"Gemini 429 ResourceExhausted em {origem}; "
                f"tentativa={tentativa}/{attempts}; aguardando={espera:.1f}s"
            )
            print(mensagem, flush=True)
            logger.warning(mensagem)
            time.sleep(espera)


def geraDocumento(arquivo):
    with open(arquivo, "rb") as file:
        encoded_string = base64.b64encode(file.read()).decode('utf-8')


    document1 = types.Part.from_bytes(
        mime_type="application/pdf",
        data=base64.b64decode(encoded_string),
    )

    return document1


def geraImagem(arquivo):
    with open(arquivo, "rb") as file:
        encoded_string = base64.b64encode(file.read()).decode('utf-8')


    document1 = types.Part.from_bytes(
        mime_type="image/png",
        data=base64.b64decode(encoded_string),
    )

    return document1





def generate(arquivo, seguradora=None, perfil=None):
    with open(arquivo, "rb") as file:
        encoded_string = base64.b64encode(file.read()).decode("utf-8")

    document1 = types.Part.from_bytes(
        mime_type="application/pdf",
        data=base64.b64decode(encoded_string),
    )
    modelo = modelo_orcamento(seguradora, arquivo=arquivo, perfil=perfil)
    text1 = modelo["prompt"]
    generation_config = {
        "max_output_tokens": 8192,
        "temperature": 1,
        "top_p": 0.95,
        "response_mime_type": "application/json",
        "response_schema": modelo["schema"],
    }

    safety_settings = [
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
    ]



    client = _gemini_client()
    responses = _generate_content_with_retry(
        client,
        [document1, text1],
        generation_config,
        safety_settings,
        modelo["nome_schema"],
    )

    jsonResult = responses.text

    jsonResult = _parse_json_response(jsonResult, modelo["nome_schema"])

    return jsonResult

    # for response in responses:
        # print(response.text, end="")


def extrair_dados_faturamento(arquivo):
    document1 = geraDocumento(arquivo)
    generation_config = {
        "max_output_tokens": 2048,
        "temperature": 0,
        "top_p": 0.95,
        "response_mime_type": "application/json",
        "response_schema": DADOS_FATURAMENTO_SCHEMA,
    }
    safety_settings = [
        types.SafetySetting(
            category=category,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH,
        )
        for category in (
            types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            types.HarmCategory.HARM_CATEGORY_HARASSMENT,
        )
    ]
    response = _generate_content_with_retry(
        _gemini_client(),
        [document1, DADOS_FATURAMENTO_PROMPT],
        generation_config,
        safety_settings,
        "dados_faturamento_allianz",
    )
    return _parse_json_response(response.text, "dados_faturamento_allianz")





def verificarTQ(documento):
    try:
        document1 = geraDocumento(documento)

        text1 = """Preciso que responda com SIM ou NAO se o documento foi assinado no campo Segurado/Terceiro e qual o nome da seguradora que consta no documento."""

        generation_config = {
            "max_output_tokens": 8192,
            "temperature": 1,
            "top_p": 0.95,
            "response_mime_type": "application/json",
            "response_schema": {"type_":"OBJECT","properties":{"dados":{"type_":"OBJECT","properties":{"assinaturaSegurado":{"type_":"STRING"},"seguradora":{"type_":"STRING"}}}}},
        }

        safety_settings = [
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
                threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
            ),
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
                threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
            ),
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
                threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
            ),
            types.SafetySetting(
                category=types.HarmCategory.HARM_CATEGORY_HARASSMENT,
                threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
            ),
        ]

        try:
            client = _gemini_client()

            responses = _generate_content_with_retry(
                client,
                [text1, document1],
                generation_config,
                safety_settings,
                "verificarTQ",
            )

            jsonResult = responses.text

            jsonResult = _parse_json_response(jsonResult, "verificarTQ")

            return jsonResult

        except Exception as e:
            print(f"Erro ao gerar o conteúdo: {str(e)}")

    except Exception as e:
        print(f"Erro ao realizar alguma coisa... {str(e)}")


def analisaPrint(documento, response_schema, texto):

    document1 = geraImagem(documento)
    # text1 = texto

    text1 = """Preciso que você pegue quatro informações no print. 1 - número que está entre parenteses na linha Empresa. 2 - número que está entre parenteses na linha Seguradora. 3 - linha veiculo. 4 - linha cliente. Retorne os dados conforme o Schema."""

    generation_config = {
        "max_output_tokens": 8192,
        "temperature": 1,
        "top_p": 0.95,
        "response_mime_type": "application/json",
        "response_schema": response_schema,
    }

    safety_settings = [
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
    ]

    print('executando o gemini')
    try:
        client = _gemini_client()

        responses = _generate_content_with_retry(
            client,
            [text1, document1],
            generation_config,
            safety_settings,
            "analisaPrint",
        )

        jsonResult = responses.text

        jsonResult = _parse_json_response(jsonResult, "analisaPrint")

        return jsonResult

    except Exception as e:
        print(f"Erro ao gerar o conteúdo: {str(e)}")

            




def loadCPGemini(documento, response_schema, text1):

    document1 = geraImagem(documento)
    # text1 = texto

    generation_config = {
        "max_output_tokens": 8192,
        "temperature": 1,
        "top_p": 0.95,
        "response_mime_type": "application/json",
        "response_schema": response_schema,
    }

    safety_settings = [
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HATE_SPEECH,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
        types.SafetySetting(
            category=types.HarmCategory.HARM_CATEGORY_HARASSMENT,
            threshold=types.HarmBlockThreshold.BLOCK_ONLY_HIGH
        ),
    ]

    print('executando o gemini')
    try:
        client = _gemini_client()

        responses = _generate_content_with_retry(
            client,
            [text1, document1],
            generation_config,
            safety_settings,
            "loadCPGemini",
        )

        jsonResult = responses.text

        jsonResult = _parse_json_response(jsonResult, "loadCPGemini")

        return jsonResult

    except Exception as e:
        print(f"Erro ao gerar o conteúdo: {str(e)}")

            
