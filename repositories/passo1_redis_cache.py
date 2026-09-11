import json
import os
from typing import Iterable

from core.env import load_dotenv
from core.models import ResultadoConsolidacao


class Passo1RedisCache:
    def __init__(
        self,
        redis_url: str | None = None,
        ttl_seconds: int | None = None,
    ):
        load_dotenv()
        self.redis_url = redis_url or os.getenv("REDIS_URL")
        if not self.redis_url:
            raise RuntimeError("REDIS_URL nao configurada para gravar o Passo 1 no Redis.")
        self.ttl_seconds = ttl_seconds or int(os.getenv("PASSO1_REDIS_TTL_SECONDS", "86400"))
        import redis

        self.client = redis.Redis.from_url(
            self.redis_url,
            decode_responses=True,
            protocol=2,
        )

    def salvar(self, resultado: ResultadoConsolidacao) -> None:
        payload = resultado.to_dict()
        codigo = resultado.os
        if not codigo:
            return
        ocorrencias = ((payload.get("dados_extraidos") or {}).get("ocorrencias_passo3") or [])

        pipe = self.client.pipeline()
        pipe.setex(f"passo1:sinistro:{codigo}", self.ttl_seconds, _json(payload))
        pipe.setex(
            f"passo1:status:{codigo}",
            self.ttl_seconds,
            resultado.status_consolidacao,
        )
        pipe.setex(
            f"passo1:acao:{codigo}",
            self.ttl_seconds,
            resultado.acao_sugerida,
        )
        pipe.sadd(f"passo1:status_idx:{resultado.status_consolidacao}", codigo)
        pipe.sadd(f"passo1:acao_idx:{resultado.acao_sugerida}", codigo)
        pipe.expire(f"passo1:status_idx:{resultado.status_consolidacao}", self.ttl_seconds)
        pipe.expire(f"passo1:acao_idx:{resultado.acao_sugerida}", self.ttl_seconds)
        pipe.setex(f"passo3:ocorrencias:{codigo}", self.ttl_seconds, _json(ocorrencias))
        for ocorrencia in ocorrencias:
            comentario = (ocorrencia or {}).get("comentario")
            if not comentario:
                continue
            identificador = (ocorrencia or {}).get("id")
            if identificador:
                pipe.setex(f"msg{identificador}:{codigo}", self.ttl_seconds, comentario)
            chave = (ocorrencia or {}).get("chave")
            if chave:
                pipe.setex(f"{chave}:{codigo}", self.ttl_seconds, comentario)
        pipe.execute()

    def salvar_lote(self, resultados: Iterable[ResultadoConsolidacao]) -> None:
        for resultado in resultados:
            self.salvar(resultado)

    def buscar(self, codigo: str):
        value = self.client.get(f"passo1:sinistro:{codigo}")
        if not value:
            return None
        return json.loads(value)

    def salvar_ocorrencias_passo3(self, codigo: str, ocorrencias: list[dict]) -> None:
        if not codigo:
            return
        self.client.setex(f"passo3:ocorrencias:{codigo}", self.ttl_seconds, _json(ocorrencias or []))

    def buscar_ocorrencias_passo3(self, codigo: str) -> list[dict]:
        value = self.client.get(f"passo3:ocorrencias:{codigo}")
        if not value:
            return []
        return json.loads(value) or []

    def ping(self) -> bool:
        return bool(self.client.ping())


def _json(value) -> str:
    return json.dumps(value, ensure_ascii=False, default=str)
