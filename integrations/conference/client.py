import base64
import csv
import os
import re
import unicodedata
from abc import ABC, abstractmethod
from pathlib import Path
from typing import Any, Dict, List, Optional

import requests

from core.env import PROJECT_ROOT, load_dotenv
from core.models import DadosConference, Documento, OrdemServico

CONFERENCE_WS_URL = "https://conference.atri.com.br/integra/ws.php"
TOKEN_PADRAO = "009f00da3200cf8eeefe1e8f8e6983f7"
TOKEN_NBS = "9ed05b84c797d24b41edef38ba8b1819"
TIMEOUT_SECONDS = 300
load_dotenv()


class ConferenceApiError(RuntimeError):
    pass


class ConferenceClient(ABC):
    @abstractmethod
    def listar_os_para_consolidacao(self) -> List[OrdemServico]:
        raise NotImplementedError

    @abstractmethod
    def buscar_dados_os(self, os_number: str) -> DadosConference:
        raise NotImplementedError

    @abstractmethod
    def download_documento(self, os_number: str, tipo_documento: str) -> Optional[str]:
        raise NotImplementedError


class ApiConferenceClient(ConferenceClient):
    def __init__(
        self,
        base_url: str = CONFERENCE_WS_URL,
        token_padrao: Optional[str] = None,
        token_nbs: Optional[str] = None,
        timeout: int = TIMEOUT_SECONDS,
        downloads_dir: str = "data/conference_downloads",
    ):
        self.base_url = base_url
        self.token_padrao = token_padrao or _optional_env(
            TOKEN_PADRAO,
            "TOKEN_PADRAO",
            "CONFERENCE_TOKEN_PADRAO",
        )
        self.token_nbs = token_nbs or _optional_env(
            TOKEN_NBS,
            "TOKEN_NBS",
            "CONFERENCE_TOKEN_NBS",
        )
        self.timeout = timeout
        self.downloads_dir = Path(downloads_dir)
        self._sinistros_cache: Dict[str, Dict[str, Any]] = {}

    def chamar_ws(
        self,
        acao: str,
        payload: Optional[Dict[str, Any]] = None,
        token: Optional[str] = None,
    ) -> Dict[str, Any]:
        headers = {
            "acao": acao,
            "token": token or self.token_padrao,
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "curl/7.68.0",
        }
        response = requests.post(
            self.base_url,
            headers=headers,
            data=_limpar_payload(payload or {}),
            timeout=self.timeout,
        )

        if response.status_code != 200:
            raise ConferenceApiError(
                f"Conference retornou HTTP {response.status_code}: {response.text}"
            )

        try:
            return response.json()
        except ValueError as exc:
            fallback = _parse_json_com_base64_multiline(response.text)
            if fallback is not None:
                return fallback
            raise ConferenceApiError(f"Conference retornou JSON invalido: {response.text}") from exc

    def consultar_empresas(self) -> Dict[str, Any]:
        return self.chamar_ws("consultar_empresas", token=self.token_padrao)

    def consultar_seguradoras(self) -> Dict[str, Any]:
        return self.chamar_ws("consultar_seguradoras", token=self.token_padrao)

    def cadastrar_ocorrencia_sinistros(
        self,
        codigo: str,
        descricao: str,
        data_programacao: str,
    ) -> Dict[str, Any]:
        return self.chamar_ws(
            "cadastrar_ocorrencia_sinistros",
            {
                "codigo": codigo,
                "descricao": descricao,
                "data_programacao": data_programacao,
            },
            token=self.token_padrao,
        )

    def reiniciar_reparo(self, codigo: str) -> Dict[str, Any]:
        return self.chamar_ws(
            "reiniciar_reparo",
            {"codigo": codigo},
            token=self.token_padrao,
        )

    def autorizar_emissao_nf(
        self,
        codigo: str,
        obs: str,
        valor_bruto_mo: float,
    ) -> Dict[str, Any]:
        return self.chamar_ws(
            "autorizar_emissao_nf",
            {
                "codigo": codigo,
                "obs": obs,
                "valor_bruto_mo": _format_decimal(valor_bruto_mo),
            },
            token=self.token_padrao,
        )

    def consultar_comprovante_entrega(
        self,
        nota: str,
        serie: str,
        empresa: int,
    ) -> Dict[str, Any]:
        return self.chamar_ws(
            "consultar_comprovante_entrega",
            {
                "nota": nota,
                "serie": serie,
                "empresa": empresa,
            },
            token=self.token_padrao,
        )

    def consultar_sinistros_registros(
        self,
        filtro: str = "O",
        tipo_data: int = 1,
        status: int = 5,
        empresa: Optional[int] = None,
    ) -> Dict[str, Any]:
        payload = {
            "filtro": filtro,
            "tipo_data": tipo_data,
            "status": status,
            "empresa": empresa,
        }
        return self.chamar_ws("consultar_sinistros_registros", payload, token=self.token_padrao)

    def consultar_sinistros_anexos(self, codigo: str) -> Dict[str, Any]:
        return self.chamar_ws(
            "consultar_sinistros_anexos",
            {"codigo": codigo},
            token=self.token_padrao,
        )

    def consultar_sinistros_anexo_pdf(self, codigo: str, codigo_anexo: str) -> Dict[str, Any]:
        return self.chamar_ws(
            "consultar_sinistros_anexo_pdf",
            {"codigo": codigo, "codigo_anexo": codigo_anexo},
            token=self.token_padrao,
        )

    def normalizar_registros(self, dados: Any) -> List[Dict[str, Any]]:
        return _normalizar_lista(dados)

    def cache_sinistro(self, registro: Dict[str, Any]) -> None:
        codigo = _primeiro_valor(registro, ["codigo", "os", "ordem_servico", "numero_os"])
        if codigo:
            self._sinistros_cache[str(codigo)] = registro

    def baixar_sinistro_anexo_pdf(
        self,
        codigo: str,
        codigo_anexo: str,
        nome_arquivo: Optional[str] = None,
    ) -> Optional[str]:
        resposta = self.consultar_sinistros_anexo_pdf(codigo, codigo_anexo)
        conteudo_base64 = _extrair_base64(resposta.get("dados"))
        if not conteudo_base64:
            return None

        self.downloads_dir.mkdir(parents=True, exist_ok=True)
        destino = self.downloads_dir / (nome_arquivo or f"{codigo}_{codigo_anexo}.pdf")
        destino.write_bytes(base64.b64decode(conteudo_base64))
        return os.fspath(destino)

    def listar_os_para_consolidacao(self) -> List[OrdemServico]:
        resposta = self.consultar_sinistros_registros()
        dados = _normalizar_lista(resposta.get("dados"))
        ordens = []

        for registro in dados:
            numero = _primeiro_valor(registro, ["codigo"])
            if not numero:
                continue
            ordem = OrdemServico(
                numero=str(numero),
                seguradora=str(_primeiro_valor(registro, ["seguradora", "cia", "cia_seguradora"]) or ""),
                dados_api=registro,
            )
            ordens.append(ordem)
            self._sinistros_cache[ordem.numero] = registro

        return ordens

    def buscar_dados_os(self, os_number: str) -> DadosConference:
        registro = self._sinistros_cache.get(os_number)
        if registro is None:
            registros = _normalizar_lista(self.consultar_sinistros_registros().get("dados"))
            for item in registros:
                codigo = item.get("codigo")
                if codigo not in (None, "") and str(codigo) == str(os_number):
                    registro = item
                    self._sinistros_cache[os_number] = item
                    break

        registro = registro or {}
        valor_pecas = _to_float(_primeiro_valor(registro, ["valor_pecas", "tot_pecas"]))
        valor_servicos = _to_float(_primeiro_valor(registro, ["valor_servicos", "tot_servicos"]))
        return DadosConference(
            os=_to_str(_primeiro_valor(registro, ["os", "ordem_servico", "numero_os"])) or str(os_number),
            codigo=_to_str(_primeiro_valor(registro, ["codigo"])),
            seguradora=str(_primeiro_valor(registro, ["seguradora", "cia", "cia_seguradora"]) or ""),
            empresa=_to_str(_primeiro_valor(registro, ["empresa"])),
            seguradora_codigo=_to_str(_primeiro_valor(registro, ["seguradora_codigo"])),
            cnpj_empresa=_primeiro_valor(registro, ["cnpj_empresa", "cnpj_oficina"]),
            cnpj_seguradora=_primeiro_valor(registro, ["cnpj_seguradora", "cnpj_cia", "seguradora_cnpj"]),
            intermediadora_codigo=_to_str(_primeiro_valor(registro, ["intermediadora_codigo"])),
            intermediadora=_to_str(_primeiro_valor(registro, ["intermediadora"])),
            nota=_to_str(_primeiro_valor(registro, ["nota"])),
            data=_to_str(_primeiro_valor(registro, ["data"])),
            serie=_to_str(_primeiro_valor(registro, ["serie"])),
            chassi=_to_str(_primeiro_valor(registro, ["chassi"])),
            placa=_to_str(_primeiro_valor(registro, ["placa"])),
            sinistro=_to_str(_primeiro_valor(registro, ["sinistro"])),
            pedido_seguradora=_to_str(_primeiro_valor(registro, ["pedido_seguradora"])),
            status=_to_str(_primeiro_valor(registro, ["status"])),
            valor_servicos=valor_servicos,
            valor_pecas=valor_pecas,
            valor_total=_valor_total(registro, valor_pecas, valor_servicos),
            valor_franquia=_to_float(_primeiro_valor(registro, ["valor_franquia", "franquia"])),
            complemento=_primeiro_valor(
                registro,
                [
                    "complemento",
                    "complementar",
                    "tem_complemento",
                    "possui_complemento",
                    "orcamento_complementar",
                    "complemento_orcamento",
                    "ind_complemento",
                ],
            ),
            anexos=[],
            raw=registro,
        )

    def download_documento(self, os_number: str, tipo_documento: str) -> Optional[str]:
        registro = self._sinistros_cache.get(os_number) or self.buscar_dados_os(os_number).raw
        codigo = _primeiro_valor(registro, ["codigo", "codigo_sinistro", "sinistro"])
        if not codigo:
            return None

        resposta = self.consultar_sinistros_anexos(str(codigo))
        anexos = _normalizar_lista(resposta.get("dados"))
        anexo = _encontrar_anexo(anexos, tipo_documento)
        if not anexo:
            return None

        codigo_anexo = _primeiro_valor(anexo, ["codigo", "codigo_anexo", "id"])
        if not codigo_anexo:
            return None

        nome_arquivo = f"{os_number}_{tipo_documento}_{codigo_anexo}.pdf"
        return self.baixar_sinistro_anexo_pdf(str(codigo), str(codigo_anexo), nome_arquivo)


class CsvMockConferenceClient(ConferenceClient):
    """
    Implementacao temporaria para desenvolvimento.

    Le as OSs de um CSV no formato atual:
    os;seguradora

    Para simular downloads, procura arquivos em:
    data/mock_downloads/{os}/{tipo}.pdf
    """

    def __init__(self, csv_path: str = "os.csv", downloads_dir: str = "data/mock_downloads"):
        self.csv_path = Path(csv_path)
        self.downloads_dir = Path(downloads_dir)
        self._os_cache = {}

    def listar_os_para_consolidacao(self) -> List[OrdemServico]:
        if not self.csv_path.exists():
            return []

        with self.csv_path.open(mode="r", newline="") as csvfile:
            reader = csv.DictReader(csvfile, delimiter=";")
            ordens = [
                OrdemServico(
                    numero=(row.get("os") or "").strip(),
                    seguradora=(row.get("seguradora") or "").strip(),
                    dados_api=row,
                )
                for row in reader
                if (row.get("os") or "").strip()
            ]

        self._os_cache = {ordem.numero: ordem for ordem in ordens}
        return ordens

    def buscar_dados_os(self, os_number: str) -> DadosConference:
        ordem = self._os_cache.get(os_number) or OrdemServico(os_number, "")
        return DadosConference(
            os=os_number,
            seguradora=ordem.seguradora,
            cnpj_empresa=ordem.dados_api.get("cnpj_empresa"),
            cnpj_seguradora=ordem.dados_api.get("cnpj_seguradora"),
            valor_servicos=_to_float(ordem.dados_api.get("valor_servicos")),
            valor_pecas=_to_float(ordem.dados_api.get("valor_pecas")),
            valor_total=_to_float(ordem.dados_api.get("valor_total")),
            valor_franquia=_to_float(ordem.dados_api.get("valor_franquia")),
            checklist={},
            anexos=[
                Documento(tipo="orcamento_final", nome="orcamento_final"),
                Documento(tipo="termo_quitacao", nome="termo_quitacao"),
            ],
            raw=ordem.dados_api,
        )

    def download_documento(self, os_number: str, tipo_documento: str) -> Optional[str]:
        base = self.downloads_dir / str(os_number)
        candidatos = [
            base / f"{tipo_documento}.pdf",
            base / f"{tipo_documento}.PDF",
        ]

        for candidato in candidatos:
            if candidato.exists():
                return os.fspath(candidato)

        return None


def build_conference_client() -> ConferenceClient:
    usar_mock = os.getenv("CONFERENCE_USE_MOCK", "").strip().lower() in ("1", "true", "sim", "yes")
    if usar_mock:
        return CsvMockConferenceClient(
            csv_path=os.getenv("CONFERENCE_MOCK_OS_CSV", "os.csv"),
            downloads_dir=os.getenv("CONFERENCE_MOCK_DOWNLOADS_DIR", "data/mock_downloads"),
        )

    return ApiConferenceClient(
        base_url=os.getenv("CONFERENCE_API_BASE_URL", CONFERENCE_WS_URL),
        token_padrao=_optional_env(TOKEN_PADRAO, "TOKEN_PADRAO", "CONFERENCE_TOKEN_PADRAO"),
        token_nbs=_optional_env(TOKEN_NBS, "TOKEN_NBS", "CONFERENCE_TOKEN_NBS"),
        timeout=int(os.getenv("CONFERENCE_TIMEOUT_SECONDS", TIMEOUT_SECONDS)),
        downloads_dir=os.getenv("CONFERENCE_DOWNLOADS_DIR", "data/conference_downloads"),
    )


def _optional_env(default: str, *names: str) -> str:
    for name in names:
        value = os.getenv(name)
        if value:
            return value

    return default


def _to_float(value):
    if value in (None, ""):
        return None
    normalized = str(value).strip()
    if "," in normalized:
        normalized = normalized.replace(".", "").replace(",", ".")
    try:
        return float(normalized)
    except ValueError:
        return None


def _format_decimal(value) -> str:
    parsed = _to_float(value)
    if parsed is None:
        parsed = 0.0
    return f"{parsed:.2f}"


def _valor_total(registro: Dict[str, Any], valor_pecas: Optional[float], valor_servicos: Optional[float]):
    valor_total = _to_float(_primeiro_valor(registro, ["valor", "valor_total", "total", "saldo"]))
    if valor_total is not None:
        return valor_total
    if valor_pecas is None or valor_servicos is None:
        return None
    return round(valor_pecas + valor_servicos, 2)


def _int_env(name: str, default: int) -> int:
    try:
        return int(os.getenv(name, str(default)))
    except (TypeError, ValueError):
        return default


def _limpar_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    return {key: value for key, value in payload.items() if value is not None}


def _parse_json_com_base64_multiline(text: str) -> Optional[Dict[str, Any]]:
    codigo_match = re.search(r'"codigo"\s*:\s*(\d+)', text)
    mensagem_match = re.search(r'"mensagem"\s*:\s*"([^"]*)"', text)
    dados_match = re.search(r'"dados"\s*:\s*"(?P<dados>[A-Za-z0-9+/=\s]+)"\s*\}', text)

    if not codigo_match or not dados_match:
        return None

    dados = re.sub(r"\s+", "", dados_match.group("dados"))
    return {
        "codigo": int(codigo_match.group(1)),
        "mensagem": mensagem_match.group(1) if mensagem_match else "",
        "dados": dados,
    }


def _normalizar_lista(value: Any) -> List[Dict[str, Any]]:
    if isinstance(value, list):
        return [item for item in value if isinstance(item, dict)]
    if isinstance(value, dict):
        return list(value.values()) if all(isinstance(item, dict) for item in value.values()) else [value]
    return []


def _primeiro_valor(registro: Dict[str, Any], campos: List[str]):
    for campo in campos:
        valor = registro.get(campo)
        if valor not in (None, ""):
            return valor
    return None


def _to_str(value: Any) -> Optional[str]:
    if value in (None, ""):
        return None
    return str(value)


def _normalizar_texto(value: Any) -> str:
    texto = str(value or "").strip().lower().replace("_", " ")
    return "".join(
        char for char in unicodedata.normalize("NFKD", texto) if not unicodedata.combining(char)
    )


def _extrair_base64(value: Any) -> Optional[str]:
    if isinstance(value, str):
        return value
    if isinstance(value, dict):
        return _primeiro_valor(value, ["base64", "pdf", "arquivo", "conteudo", "dados"])
    return None


def _encontrar_anexo(anexos: List[Dict[str, Any]], tipo_documento: str) -> Optional[Dict[str, Any]]:
    alvo = _normalizar_texto(tipo_documento)
    aliases = {
        "orcamento_final": [
            "orcamento final",
            "orcamento",
            "final",
            "autorizacao de reparos",
            "reparos",
            "os corrigida",
        ],
        "termo_quitacao": ["termo quitacao", "termo de quitacao", "quitacao"],
        "dados_faturamento": ["dados para faturamento"],
    }
    termos = aliases.get(tipo_documento, [alvo])

    descricoes = [
        (
            anexo,
            _normalizar_texto(
                _primeiro_valor(anexo, ["descricao", "nome", "tipo", "arquivo", "titulo"])
            ),
        )
        for anexo in anexos
    ]

    for termo in termos:
        for anexo, descricao in descricoes:
            if termo in descricao:
                return anexo

    return None
