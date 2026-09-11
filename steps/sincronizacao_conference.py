import logging
from typing import Optional

from integrations.conference.client import ApiConferenceClient


logger = logging.getLogger(__name__)


class SincronizacaoConference:
    def __init__(self, conference_client: ApiConferenceClient, repository=None):
        self.conference_client = conference_client
        self.repository = repository

    def executar(
        self,
        tipo_data: int = 1,
        status: int = 5,
        empresa: Optional[int] = None,
    ) -> dict:
        resposta = self.conference_client.consultar_sinistros_registros(
            filtro="O",
            tipo_data=tipo_data,
            status=status,
            empresa=empresa,
        )
        self._validar_resposta_conference(resposta, "consultar_sinistros_registros")

        codigos_ativos = []
        sincronizados = 0
        ignorados = 0
        registros = self.conference_client.normalizar_registros(resposta.get("dados"))

        print(
            f"SYNC_BASE inicio total={len(registros)} tipo_data={tipo_data} status={status} empresa={empresa}",
            flush=True,
        )
        logger.info(
            "SYNC_BASE inicio total=%s tipo_data=%s status=%s empresa=%s",
            len(registros),
            tipo_data,
            status,
            empresa,
        )

        for registro in registros:
            codigo = _codigo_registro(registro)
            if not codigo:
                ignorados += 1
                print(f"SYNC_BASE registro ignorado sem codigo: {registro}", flush=True)
                logger.info("SYNC_BASE registro ignorado sem codigo: %s", registro)
                continue

            codigos_ativos.append(codigo)
            print(
                f"SYNC_BASE sincronizando codigo={codigo} os={registro.get('os')} "
                f"seguradora={registro.get('seguradora')} empresa={registro.get('empresa')} "
                f"status={registro.get('status')}",
                flush=True,
            )
            logger.info(
                "SYNC_BASE sincronizando codigo=%s os=%s seguradora=%s empresa=%s status=%s",
                codigo,
                registro.get("os"),
                registro.get("seguradora"),
                registro.get("empresa"),
                registro.get("status"),
            )
            self.conference_client.cache_sinistro(registro)
            self._sincronizar_snapshot_conference(registro)
            sincronizados += 1

        inativadas = self._remover_consolidacoes_fora_retrieve(codigos_ativos, empresa=empresa)
        resultado = {
            "ok": True,
            "checkpoint": "SINCRONIZACAO_CONFERENCE",
            "sincronizados": sincronizados,
            "ignorados": ignorados,
            "inativadas": inativadas,
            "removidas": inativadas,
            "encerradas": inativadas,
            "ativos": len(codigos_ativos),
            "tipo_data": tipo_data,
            "status": status,
            "empresa": empresa,
        }
        print(f"SYNC_BASE concluida resultado={resultado}", flush=True)
        logger.info("SYNC_BASE concluida resultado=%s", resultado)
        return resultado

    def _sincronizar_snapshot_conference(self, registro: dict) -> None:
        if not self.repository or not hasattr(self.repository, "sincronizar_snapshot_conference"):
            raise RuntimeError("Repositorio nao suporta sincronizacao de snapshots do Conference.")
        self.repository.sincronizar_snapshot_conference(registro)

    def _remover_consolidacoes_fora_retrieve(
        self,
        codigos_ativos: list[str],
        empresa: Optional[int] = None,
    ) -> int:
        if self.repository and hasattr(self.repository, "remover_consolidacoes_fora_retrieve"):
            return self.repository.remover_consolidacoes_fora_retrieve(codigos_ativos, empresa=empresa)
        return 0

    def _validar_resposta_conference(self, resposta: dict, acao: str) -> None:
        if str((resposta or {}).get("codigo") or "") == "1":
            return
        mensagem = (resposta or {}).get("mensagem") or "Sem mensagem de erro."
        raise RuntimeError(f"{acao} falhou: {mensagem}")


def _codigo_registro(registro: dict) -> str:
    for chave in ("codigo", "os", "ordem_servico", "numero_os"):
        valor = registro.get(chave)
        if valor not in (None, ""):
            return str(valor)
    raw = registro.get("raw") or {}
    for chave in ("codigo", "os", "ordem_servico", "numero_os"):
        valor = raw.get(chave)
        if valor not in (None, ""):
            return str(valor)
    return ""
