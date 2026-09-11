import logging
from dataclasses import asdict
from functools import lru_cache
from typing import Any, Optional

from fastapi import Body, FastAPI, HTTPException, Query
from pydantic import BaseModel, Field
from requests import RequestException

from integrations.conference.client import (
    ApiConferenceClient,
    ConferenceApiError,
    build_conference_client,
)
from modules.seguradora.cnpjs import dados as regras_cnpj_seed
from repositories.mysql_consolidacao_repository import MySqlConsolidacaoRepository
from repositories.passo1_redis_cache import Passo1RedisCache
from steps.passo_1_consolidacao.triagem import Passo1TriagemConference
from steps.passo_3_fechamento.executar import Passo3Fechamento
from steps.sincronizacao_conference import SincronizacaoConference
logger = logging.getLogger(__name__)

app = FastAPI(
    title="ATRI RPA - Conference API",
    version="0.1.0",
    description="Proxy HTTP para consumo dos servicos Conference ws.php.",
)


class OcorrenciaRequest(BaseModel):
    codigo: str = Field(..., examples=["123456"])
    descricao: str = Field(..., examples=["Validacao realizada pelo RPA."])
    data_programacao: str = Field(..., examples=["03/06/2026"])


class ComprovanteEntregaRequest(BaseModel):
    nota: str = Field(..., examples=["12345"])
    serie: str = Field(..., examples=["1"])
    empresa: int = Field(..., examples=[1])


class SinistroRegistrosRequest(BaseModel):
    tipo_data: int = Field(1, examples=[1])
    status: int = Field(5, examples=[5])
    empresa: Optional[int] = Field(None, examples=[1])


class RedisSetRequest(BaseModel):
    key: str = Field(..., min_length=1, examples=["minha-chave"])
    value: str = Field(..., examples=["valor em string"])


class RedisGetRequest(BaseModel):
    key: str = Field(..., min_length=1, examples=["minha-chave"])


def _conference_client() -> ApiConferenceClient:
    client = build_conference_client()
    if not isinstance(client, ApiConferenceClient):
        raise HTTPException(
            status_code=500,
            detail="CONFERENCE_USE_MOCK esta ativo. Desative para expor a API real.",
        )
    return client


def _executar_chamada(func, *args, **kwargs):
    try:
        return func(*args, **kwargs)
    except ConferenceApiError as exc:
        raise HTTPException(status_code=502, detail=str(exc)) from exc
    except RequestException as exc:
        raise HTTPException(status_code=504, detail=f"Falha ao chamar Conference: {exc}") from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc


@lru_cache(maxsize=1)
def _mysql_repository() -> MySqlConsolidacaoRepository:
    return MySqlConsolidacaoRepository()


@lru_cache(maxsize=1)
def _redis_cache() -> Passo1RedisCache:
    return Passo1RedisCache()


def _passo1_triagem(cancel_checker=None, progress_callback=None) -> Passo1TriagemConference:
    return Passo1TriagemConference(
        _conference_client(),
        repository=_mysql_repository(),
        cache=_redis_cache(),
        cancel_checker=cancel_checker,
        progress_callback=progress_callback,
    )


def _passo3_fechamento() -> Passo3Fechamento:
    return Passo3Fechamento(
        _conference_client(),
        repository=_mysql_repository(),
        cache=_redis_cache(),
    )


def _sincronizacao_conference() -> SincronizacaoConference:
    return SincronizacaoConference(
        _conference_client(),
        repository=_mysql_repository(),
    )


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/health/storage")
def health_storage():
    mysql_ok = False
    redis_ok = False
    mysql_error = None
    redis_error = None

    try:
        with _mysql_repository()._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT 1 AS ok")
                mysql_ok = bool(cursor.fetchone())
    except Exception as exc:
        mysql_error = _safe_error(exc)
        mysql_ok = False

    try:
        redis_ok = _redis_cache().ping()
    except Exception as exc:
        redis_error = _safe_error(exc)
        redis_ok = False

    return {
        "mysql": "ok" if mysql_ok else "erro",
        "redis": "ok" if redis_ok else "erro",
        "mysql_error": mysql_error,
        "redis_error": redis_error,
    }


@app.post("/redis/set")
@app.post("/api/redis/set")
def redis_set(payload: RedisSetRequest):
    key = payload.key.strip()
    if not key:
        raise HTTPException(status_code=400, detail="Informe key.")

    try:
        # SET simples, sem EX/TTL. Esse registro deve permanecer no Redis ate
        # remocao explicita fora desta API.
        result = _redis_cache().client.set(key, payload.value)
        return {"ok": bool(result), "key": key}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=_safe_error(exc)) from exc


@app.post("/redis/get")
@app.post("/api/redis/get")
def redis_get(payload: RedisGetRequest):
    key = payload.key.strip()
    if not key:
        raise HTTPException(status_code=400, detail="Informe key.")

    try:
        value = _redis_cache().client.get(key)
        return {"ok": True, "key": key, "found": value is not None, "value": value}
    except Exception as exc:
        raise HTTPException(status_code=500, detail=_safe_error(exc)) from exc


def _safe_error(exc: Exception) -> str:
    return str(exc).replace("\n", " ")[:500]


@app.get("/dashboard/consolidacoes")
def dashboard_consolidacoes(limit: int = Query(500, ge=1, le=2000)):
    try:
        repository = _mysql_repository()
        return repository.dashboard_consolidacoes(limit=limit)
    except Exception as exc:
        return {
            "ok": False,
            "error": _safe_dashboard_error(exc),
            "totals": {
                "total": 0,
                "aprovadas": 0,
                "pendentes": 0,
                "reprovadas": 0,
                "erros": 0,
                "naoAnalisadas": 0,
                "curadorAprovadas": 0,
                "aguardandoCuradoria": 0,
                "automaticos": 0,
                "valorTotal": 0,
                "aprovadoValor": 0,
                "pendenteValor": 0,
            },
            "timeline": [],
            "byStatus": [],
            "byAction": [],
            "bySeguradora": [],
            "byValidation": [],
            "items": [],
        }


@app.post("/dashboard/consolidacoes/{codigo}/aprovar")
def aprovar_consolidacao_curador(codigo: str):
    try:
        repository = _mysql_repository()
        result = repository.aprovar_consolidacao_curador(codigo)
        if not result.get("ok"):
            raise HTTPException(status_code=404, detail=result.get("error"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=_safe_dashboard_error(exc)) from exc


@app.post("/dashboard/consolidacoes/{codigo}/cnpj")
def revisar_cnpj_consolidacao(codigo: str, aprovado: bool = Body(...)):
    try:
        repository = _mysql_repository()
        result = repository.revisar_cnpj_tokio(codigo, aprovado=aprovado)
        if not result.get("ok"):
            raise HTTPException(status_code=400, detail=result.get("error"))
        return result
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=_safe_dashboard_error(exc)) from exc


@app.get("/dashboard/fechamentos")
def dashboard_fechamentos(limit: int = Query(500, ge=1, le=2000)):
    try:
        repository = _mysql_repository()
        return repository.dashboard_fechamentos(limit=limit)
    except Exception as exc:
        return {
            "ok": False,
            "error": _safe_dashboard_error(exc),
            "totals": {
                "total": 0,
                "valorAprovado": 0,
                "erros": 0,
                "pendentes": 0,
            },
            "timeline": [],
            "byStatus": [],
            "byDecision": [],
            "items": [],
        }


@app.get("/dashboard/execucoes")
def dashboard_execucoes(limit: int = Query(500, ge=1, le=2000)):
    try:
        repository = _mysql_repository()
        return repository.dashboard_execucoes(limit=limit)
    except Exception as exc:
        return {
            "ok": False,
            "error": _safe_dashboard_error(exc),
            "totals": {
                "total": 0,
                "encerradasManualmente": 0,
                "comErro": 0,
            },
            "timeline": [],
            "byStatus": [],
            "byAction": [],
            "items": [],
        }


@app.get("/dashboard/os-login-senhas")
def listar_os_login_senhas(
    limit: int = Query(1000, ge=1, le=5000),
    seguradora: Optional[str] = Query(None),
    empresa: Optional[str] = Query(None),
    incluir_senha: bool = Query(False),
):
    try:
        repository = _mysql_repository()
        return repository.listar_os_login_senhas(
            limit=limit,
            seguradora=seguradora,
            empresa=empresa,
            incluir_senha=incluir_senha,
        )
    except Exception as exc:
        return {
            "ok": False,
            "error": _safe_dashboard_error(exc),
            "totals": {
                "total": 0,
                "comCredenciais": 0,
                "semCredenciais": 0,
                "credenciais": 0,
            },
            "bySeguradora": [],
            "byEmpresa": [],
            "items": [],
        }


@app.post("/dashboard/portais-senhas/importar-lote")
def importar_portais_senhas_lote(payload: Any = Body(...)):
    try:
        repository = _mysql_repository()
        return repository.importar_portais_senhas_lote(payload)
    except Exception as exc:
        raise HTTPException(status_code=400, detail=_safe_dashboard_error(exc)) from exc


@app.get("/dashboard/portais-senhas")
def dashboard_portais_senhas():
    try:
        repository = _mysql_repository()
        return repository.dashboard_portais_senhas()
    except Exception as exc:
        return {
            "ok": False,
            "error": _safe_dashboard_error(exc),
            "seguradoras": [],
            "items": [],
        }


@app.post("/passo3/fechamento")
def executar_fila_fechamento(
    limit: int = Query(100, ge=1, le=500),
    dry_run: bool = Query(False),
    automaticos: bool = Query(False),
):
    passo3 = _passo3_fechamento()
    return _executar_chamada(passo3.executar_fila, limit=limit, dry_run=dry_run, automaticos=automaticos)


@app.post("/passo2/curadoria-automatica")
def executar_passo2_curadoria_automatica(
    limit: int = Query(100, ge=1, le=500),
    dry_run: bool = Query(False),
):
    repository = _mysql_repository()
    return _executar_chamada(
        repository.executar_passo2_curadoria_automatica,
        limit=limit,
        dry_run=dry_run,
        responsavel="rpa",
    )


@app.post("/passo3/fechamento/{codigo}")
def executar_fechamento_os(
    codigo: str,
    dry_run: bool = Query(False),
):
    passo3 = _passo3_fechamento()
    resultado = _executar_chamada(passo3.executar_os, codigo, dry_run=dry_run)
    if not resultado.get("ok"):
        raise HTTPException(status_code=404, detail=resultado.get("erro"))
    return resultado


@app.post("/processamento/{codigo}/forcar")
def forcar_processamento_os(codigo: str):
    passo1 = _executar_chamada(
        _passo1_triagem().executar_codigo,
        codigo=codigo,
        forcar=True,
        reler_orcamento=True,
        reler_documentos=True,
        ignorar_complemento_manual=True,
        forcar_releitura=True,
    )

    passo2 = _executar_chamada(
        _mysql_repository().executar_passo2_curadoria_automatica,
        limit=1,
        dry_run=False,
        responsavel="rpa_forcado",
        os_number=codigo,
    )
    enfileirado = any(
        item.get("acao") in {"APROVAR", "RETORNAR_OFICINA"}
        for item in (passo2.get("resultados") or [])
    )
    if enfileirado:
        passo3 = _executar_chamada(_passo3_fechamento().executar_os, codigo, dry_run=False)
    else:
        passo3 = {
            "ok": True,
            "ignorado": True,
            "motivo": "Passo 2 nao gerou uma decisao elegivel para o Passo 3.",
        }

    return {
        "ok": bool(passo3.get("ok")),
        "os": codigo,
        "passo1": passo1.to_dict(),
        "passo2": passo2,
        "passo3": passo3,
    }


def _safe_dashboard_error(exc: Exception) -> str:
    message = str(exc).replace("\n", " ")
    if "Access denied" in message or "Authentication failed" in message:
        return "Falha de autenticacao ao consultar o banco de dados."
    return message[:300]


@app.get("/empresas")
def consultar_empresas():
    client = _conference_client()
    return _executar_chamada(client.consultar_empresas)


@app.get("/seguradoras")
def consultar_seguradoras():
    client = _conference_client()
    return _executar_chamada(client.consultar_seguradoras)


@app.post("/cadastros/sincronizar")
def sincronizar_cadastros(
    tipo_data: int = Query(1),
    status: int = Query(5),
    empresa: Optional[int] = Query(None),
):
    client = _conference_client()
    repository = _mysql_repository()
    sincronizacao = _sincronizacao_conference()

    empresas_response = _executar_chamada(client.consultar_empresas)
    seguradoras_response = _executar_chamada(client.consultar_seguradoras)

    empresas = client.normalizar_registros(empresas_response.get("dados"))
    seguradoras = client.normalizar_registros(seguradoras_response.get("dados"))

    empresas_salvas = _executar_chamada(repository.salvar_empresas, empresas)
    seguradoras_salvas = _executar_chamada(repository.salvar_seguradoras, seguradoras)
    regras_cnpj = _executar_chamada(repository.sincronizar_regras_cnpj, regras_cnpj_seed)
    sinistros = _executar_chamada(
        sincronizacao.executar,
        tipo_data=tipo_data,
        status=status,
        empresa=empresa,
    )

    return {
        "empresas": {
            "consultadas": len(empresas),
            "salvas": empresas_salvas,
            "dados": empresas,
        },
        "seguradoras": {
            "consultadas": len(seguradoras),
            "salvas": seguradoras_salvas,
            "dados": seguradoras,
        },
        "regras_cnpj": regras_cnpj,
        "sinistros": sinistros,
    }


@app.post("/cadastros/regras-cnpj/sincronizar")
def sincronizar_regras_cnpj():
    repository = _mysql_repository()
    return _executar_chamada(repository.sincronizar_regras_cnpj, regras_cnpj_seed)


@app.get("/cadastros/regras-cnpj/validar-os")
def validar_cnpjs_ordens_servico(limit: Optional[int] = Query(None, ge=1)):
    repository = _mysql_repository()
    return _executar_chamada(repository.validar_cnpjs_ordens_servico, limit=limit)


@app.post("/ocorrencia")
def cadastrar_ocorrencia(payload: OcorrenciaRequest):
    client = _conference_client()
    return _executar_chamada(
        client.cadastrar_ocorrencia_sinistros,
        codigo=payload.codigo,
        descricao=payload.descricao,
        data_programacao=payload.data_programacao,
    )


@app.get("/comprovante_entrega")
def consultar_comprovante_entrega(
    nota: str = Query(...),
    serie: str = Query(...),
    empresa: int = Query(...),
):
    client = _conference_client()
    return _executar_chamada(
        client.consultar_comprovante_entrega,
        nota=nota,
        serie=serie,
        empresa=empresa,
    )


@app.post("/comprovante_entrega")
def consultar_comprovante_entrega_post(payload: ComprovanteEntregaRequest):
    client = _conference_client()
    return _executar_chamada(
        client.consultar_comprovante_entrega,
        nota=payload.nota,
        serie=payload.serie,
        empresa=payload.empresa,
    )


@app.get("/sinistros/registros")
def consultar_sinistros_registros(
    tipo_data: int = Query(1),
    status: int = Query(5),
    empresa: Optional[int] = Query(None),
):
    client = _conference_client()
    return _executar_chamada(
        client.consultar_sinistros_registros,
        filtro="O",
        tipo_data=tipo_data,
        status=status,
        empresa=empresa,
    )


@app.post("/sinistros/registros")
def consultar_sinistros_registros_post(payload: SinistroRegistrosRequest):
    client = _conference_client()
    return _executar_chamada(
        client.consultar_sinistros_registros,
        filtro="O",
        tipo_data=payload.tipo_data,
        status=payload.status,
        empresa=payload.empresa,
    )


@app.get("/sinistros/{codigo}")
def consultar_sinistro(codigo: str):
    client = _conference_client()
    dados = _executar_chamada(client.buscar_dados_os, os_number=codigo)
    return asdict(dados)


@app.get("/passo1/consolidacao")
def listar_passo1_consolidacao(
    tipo_data: int = Query(1),
    status: int = Query(5),
    empresa: Optional[int] = Query(None),
    reler_orcamento: bool = Query(False),
    reler_documentos: bool = Query(False),
):
    triagem = _passo1_triagem()
    resultados = _executar_chamada(
        triagem.listar,
        tipo_data=tipo_data,
        status=status,
        empresa=empresa,
        reler_orcamento=reler_orcamento,
        reler_documentos=reler_documentos,
    )
    return [resultado.to_dict() for resultado in resultados]


@app.post("/passo1/consolidacao/executar")
def executar_passo1_consolidacao(
    tipo_data: int = Query(1),
    status: Optional[int] = Query(None),
    empresa: Optional[int] = Query(None),
    reler_orcamento: bool = Query(True),
    reler_documentos: bool = Query(True),
):
    parametros = {
        "tipo_data": tipo_data,
        "status": status,
        "empresa": empresa,
        "reler_orcamento": reler_orcamento,
        "reler_documentos": reler_documentos,
    }
    print(f"PASSO1 execucao unica iniciando parametros={parametros}", flush=True)
    logger.info("PASSO1 execucao unica iniciando parametros=%s", parametros)
    triagem = _passo1_triagem()
    resultados = _executar_chamada(triagem.listar, **parametros)
    resumo = {
        "analisados": len(resultados),
        "por_status": _contar_status_passo1(resultados),
    }
    print(f"PASSO1 execucao unica concluida resumo={resumo}", flush=True)
    logger.info("PASSO1 execucao unica concluida resumo=%s", resumo)
    return {"ok": True, "resultado": resumo}


def _contar_status_passo1(resultados) -> dict:
    total = {}
    for resultado in resultados:
        status = getattr(resultado, "status_consolidacao", None) or "NAO_INFORMADO"
        total[status] = total.get(status, 0) + 1
    return total


@app.get("/passo1/consolidacao/{codigo}")
def consultar_passo1_consolidacao(
    codigo: str,
    forcar: bool = Query(False),
    reler_orcamento: bool = Query(False),
    reler_documentos: bool = Query(False),
):
    triagem = _passo1_triagem()
    resultado = _executar_chamada(
        triagem.executar_codigo,
        codigo=codigo,
        forcar=forcar,
        reler_orcamento=reler_orcamento,
        reler_documentos=reler_documentos,
    )
    return resultado.to_dict()


@app.get("/passo1/consolidacao/{codigo}/validar-orcamento")
def validar_orcamento_passo1(codigo: str):
    triagem = _passo1_triagem()
    return _executar_chamada(triagem.validar_orcamento_codigo, codigo=codigo)


@app.post("/dashboard/consolidacoes/sincronizar-conference")
def sincronizar_consolidacoes_conference(
    tipo_data: int = Query(1),
    status: int = Query(5),
    empresa: Optional[int] = Query(None),
):
    sincronizacao = _sincronizacao_conference()
    return _executar_chamada(
        sincronizacao.executar,
        tipo_data=tipo_data,
        status=status,
        empresa=empresa,
    )


@app.get("/sinistros/{codigo}/anexos")
def consultar_sinistros_anexos(codigo: str):
    client = _conference_client()
    return _executar_chamada(client.consultar_sinistros_anexos, codigo=codigo)


@app.get("/sinistros/{codigo}/anexos/{codigo_anexo}/pdf")
def consultar_sinistros_anexo_pdf(codigo: str, codigo_anexo: str):
    client = _conference_client()
    return _executar_chamada(
        client.consultar_sinistros_anexo_pdf,
        codigo=codigo,
        codigo_anexo=codigo_anexo,
    )


@app.post("/sinistros/{codigo}/anexos/{codigo_anexo}/baixar")
def baixar_sinistros_anexo_pdf(codigo: str, codigo_anexo: str):
    client = _conference_client()
    arquivo = _executar_chamada(
        client.baixar_sinistro_anexo_pdf,
        codigo=codigo,
        codigo_anexo=codigo_anexo,
    )
    if not arquivo:
        raise HTTPException(status_code=404, detail="PDF nao retornado pelo Conference.")
    return {"arquivo": arquivo}
