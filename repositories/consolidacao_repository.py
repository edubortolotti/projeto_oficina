import json
import sqlite3
from pathlib import Path
from typing import Iterable

from core.models import ResultadoConsolidacao


class ConsolidacaoRepository:
    def __init__(self, database_path: str = "data/consolidacao.db"):
        self.database_path = Path(database_path)
        self.database_path.parent.mkdir(parents=True, exist_ok=True)
        self._init_schema()

    def _connect(self):
        return sqlite3.connect(self.database_path)

    def _init_schema(self) -> None:
        with self._connect() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS consolidacoes (
                    os TEXT PRIMARY KEY,
                    seguradora TEXT NOT NULL,
                    status_consolidacao TEXT NOT NULL,
                    acao_sugerida TEXT NOT NULL,
                    resultado_json TEXT NOT NULL,
                    atualizado_em TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )

    def salvar(self, resultado: ResultadoConsolidacao) -> None:
        payload = json.dumps(resultado.to_dict(), ensure_ascii=False)
        with self._connect() as conn:
            conn.execute(
                """
                INSERT INTO consolidacoes (
                    os,
                    seguradora,
                    status_consolidacao,
                    acao_sugerida,
                    resultado_json,
                    atualizado_em
                )
                VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
                ON CONFLICT(os) DO UPDATE SET
                    seguradora = excluded.seguradora,
                    status_consolidacao = excluded.status_consolidacao,
                    acao_sugerida = excluded.acao_sugerida,
                    resultado_json = excluded.resultado_json,
                    atualizado_em = CURRENT_TIMESTAMP
                """,
                (
                    resultado.os,
                    resultado.seguradora,
                    resultado.status_consolidacao,
                    resultado.acao_sugerida,
                    payload,
                ),
            )

    def salvar_lote(self, resultados: Iterable[ResultadoConsolidacao]) -> None:
        for resultado in resultados:
            self.salvar(resultado)

