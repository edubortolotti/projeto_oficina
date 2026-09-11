import unicodedata
from typing import Dict, Iterable

from core.models import ValidacaoResultado
from core.status import STATUS_APROVADO, STATUS_REPROVADO


REGRAS_ANEXOS = {
    "fotos": ["foto", "fotos", "imagem", "imagens", "vistoria"],
    "nf_fabrica": ["nf de fabrica", "nota fiscal de fabrica", "nf fabrica"],
    "conhecimento_transporte": ["conhecimento de transporte", "cte", "ct-e"],
    "dados_faturamento": ["dados para faturamento"],
}


def validar_anexos(
    downloads: Dict[str, str],
    anexos: Iterable[dict] | None = None,
    tipos_obrigatorios: Iterable[str] | None = None,
) -> ValidacaoResultado:
    arquivos = {tipo: arquivo for tipo, arquivo in (downloads or {}).items() if arquivo}
    faltantes = [tipo for tipo, arquivo in (downloads or {}).items() if not arquivo]

    encontrados = _classificar_anexos(anexos or [])
    arquivos.update(encontrados)
    for tipo in encontrados:
        if tipo in faltantes:
            faltantes.remove(tipo)
    for tipo in tipos_obrigatorios or []:
        if tipo not in arquivos and tipo not in faltantes:
            faltantes.append(tipo)

    if faltantes:
        return ValidacaoResultado(
            item="anexos",
            status=STATUS_REPROVADO,
            mensagem="Anexos obrigatorios nao foram encontrados.",
            dados={"faltantes": faltantes, "arquivos": arquivos, "anexos": list(anexos or [])},
        )

    return ValidacaoResultado(
        item="anexos",
        status=STATUS_APROVADO,
        mensagem="Anexos obrigatorios encontrados.",
        dados={"arquivos": arquivos, "anexos": list(anexos or [])},
    )


def _classificar_anexos(anexos: Iterable[dict]) -> dict:
    encontrados = {}
    for anexo in anexos:
        texto = _normalizar(
            _primeiro_valor(anexo, ["tipo", "descricao", "nome", "arquivo", "titulo"])
        )
        if not texto:
            continue
        for tipo, aliases in REGRAS_ANEXOS.items():
            if tipo in encontrados:
                continue
            if any(alias in texto for alias in aliases):
                encontrados[tipo] = {
                    "codigo": _codigo_anexo(anexo),
                    "tipo": _primeiro_valor(anexo, ["tipo", "descricao", "nome", "arquivo", "titulo"]),
                }
    return encontrados


def _primeiro_valor(registro: dict, campos: list[str]):
    for campo in campos:
        valor = registro.get(campo)
        if valor not in (None, ""):
            return valor
    return None


def _codigo_anexo(anexo: dict):
    codigo = _primeiro_valor(anexo, ["codigo", "codigo_anexo", "id"])
    if codigo not in (None, ""):
        return codigo
    metadados = anexo.get("metadados") or {}
    if isinstance(metadados, dict):
        return metadados.get("codigo") or ((metadados.get("raw") or {}).get("codigo") if isinstance(metadados.get("raw"), dict) else None)
    return None


def _normalizar(value) -> str:
    texto = str(value or "").strip().lower().replace("_", " ")
    return "".join(
        char for char in unicodedata.normalize("NFKD", texto) if not unicodedata.combining(char)
    )
