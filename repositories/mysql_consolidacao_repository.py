import base64
import hashlib
import json
import logging
import os
import uuid
from datetime import datetime
from typing import Any, Iterable
from urllib.parse import unquote, urlparse

from core.env import load_dotenv
from core.models import ResultadoConsolidacao, ValidacaoResultado
from core.status import (
    ACAO_ENVIAR_PASSO_2,
    CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO,
    STATUS_APROVADO,
    STATUS_PENDENTE,
    STATUS_REPROVADO,
)
from services.validacoes.classificador import classificar_consolidacao


logger = logging.getLogger(__name__)


OCORRENCIAS_DESATIVADAS = {"C22", "C27"}


def connect_to_db():
    import mysql.connector

    load_dotenv()
    database_url = os.getenv("DATABASE_URL")
    if database_url:
        parsed = urlparse(database_url)
        if parsed.scheme not in ("mysql", "mysql+pymysql", "mysql+mysqlconnector"):
            raise RuntimeError("DATABASE_URL deve usar o protocolo mysql.")

        return mysql.connector.connect(
            host=parsed.hostname,
            port=parsed.port or 3306,
            user=unquote(parsed.username or ""),
            password=unquote(parsed.password or ""),
            database=(parsed.path or "").lstrip("/"),
        )

    return mysql.connector.connect(
        host="console.loovree.com",
        port=3306,
        user="loovree_app",
        password="SENHA_CORRETA",
        database="rpa_oficinas",
        # ssl_options={"ssl": ssl.create_default_context()}
    )


class MySqlConsolidacaoRepository:
    def __init__(self):
        self._init_schema()

    def _connect(self):
        return connect_to_db()

    def _init_schema(self) -> None:
        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS empresas (
                        id INT NOT NULL AUTO_INCREMENT,
                        codigo VARCHAR(50) NOT NULL,
                        nome VARCHAR(180) NULL,
                        cnpj VARCHAR(20) NULL,
                        dadosApi JSON NOT NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY empresas_codigo_key (codigo),
                        KEY empresas_cnpj_idx (cnpj)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS seguradoras (
                        id INT NOT NULL AUTO_INCREMENT,
                        codigo VARCHAR(50) NOT NULL,
                        nome VARCHAR(180) NULL,
                        cnpj VARCHAR(20) NULL,
                        dadosApi JSON NOT NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY seguradoras_codigo_key (codigo),
                        KEY seguradoras_cnpj_idx (cnpj)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS seguradoras_cnpj (
                        id INT NOT NULL AUTO_INCREMENT,
                        seguradoraId INT NOT NULL,
                        cnpj VARCHAR(20) NOT NULL,
                        grupo VARCHAR(120) NULL,
                        dadosApi JSON NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY seguradoras_cnpj_seguradoraId_cnpj_key (seguradoraId, cnpj),
                        KEY seguradoras_cnpj_cnpj_idx (cnpj),
                        CONSTRAINT seguradoras_cnpj_seguradoraId_fkey
                            FOREIGN KEY (seguradoraId) REFERENCES seguradoras(id)
                            ON DELETE CASCADE ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS empresa_seguradora_cnpj (
                        id INT NOT NULL AUTO_INCREMENT,
                        empresaId INT NOT NULL,
                        seguradoraCnpjId INT NOT NULL,
                        ativo TINYINT(1) NOT NULL DEFAULT 1,
                        dadosApi JSON NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY empresa_seguradora_cnpj_empresaId_seguradoraCnpjId_key
                            (empresaId, seguradoraCnpjId),
                        KEY empresa_seguradora_cnpj_seguradoraCnpjId_idx (seguradoraCnpjId),
                        CONSTRAINT empresa_seguradora_cnpj_empresaId_fkey
                            FOREIGN KEY (empresaId) REFERENCES empresas(id)
                            ON DELETE CASCADE ON UPDATE CASCADE,
                        CONSTRAINT empresa_seguradora_cnpj_seguradoraCnpjId_fkey
                            FOREIGN KEY (seguradoraCnpjId) REFERENCES seguradoras_cnpj(id)
                            ON DELETE CASCADE ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS ordens_servico (
                        id INT NOT NULL AUTO_INCREMENT,
                        numero VARCHAR(50) NOT NULL,
                        seguradora VARCHAR(120) NOT NULL,
                        statusAtual VARCHAR(80) NULL,
                        dadosApi JSON NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY ordens_servico_numero_key (numero)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS consolidacoes (
                        id INT NOT NULL AUTO_INCREMENT,
                        ordemServicoId INT NULL,
                        os VARCHAR(50) NOT NULL,
                        seguradora VARCHAR(120) NOT NULL,
                        statusConsolidacao VARCHAR(80) NOT NULL,
                        acaoSugerida VARCHAR(80) NOT NULL,
                        execucaoId CHAR(36) NULL,
                        gatesValidacao JSON NULL,
                        dadosConference JSON NULL,
                        dadosExtraidos JSON NULL,
                        validacoes JSON NOT NULL,
                        erros JSON NULL,
                        resultadoJson JSON NOT NULL,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        UNIQUE KEY consolidacoes_os_key (os),
                        KEY consolidacoes_statusConsolidacao_idx (statusConsolidacao),
                        KEY consolidacoes_acaoSugerida_idx (acaoSugerida),
                        CONSTRAINT consolidacoes_ordemServicoId_fkey
                            FOREIGN KEY (ordemServicoId) REFERENCES ordens_servico(id)
                            ON DELETE SET NULL ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "execucaoId",
                    "CHAR(36) NULL",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "gatesValidacao",
                    "JSON NULL",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "curadorAprovado",
                    "TINYINT(1) NOT NULL DEFAULT 0",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "curadorAprovadoEm",
                    "DATETIME NULL",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "curadorResponsavel",
                    "VARCHAR(120) NULL",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "ativoConferencia",
                    "TINYINT(1) NOT NULL DEFAULT 1",
                )
                self._ensure_column(
                    cursor,
                    "consolidacoes",
                    "sincronizadoEm",
                    "DATETIME NULL",
                )
                self._ensure_index(cursor, "consolidacoes", "consolidacoes_execucaoId_idx", "execucaoId")
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS execucoes_consolidacao (
                        id CHAR(36) NOT NULL,
                        ordemServicoId INT NULL,
                        os VARCHAR(50) NOT NULL,
                        seguradora VARCHAR(120) NOT NULL,
                        statusConsolidacao VARCHAR(80) NOT NULL,
                        acaoSugerida VARCHAR(80) NOT NULL,
                        gatesValidacao JSON NOT NULL,
                        dadosConference JSON NULL,
                        dadosExtraidos JSON NULL,
                        validacoes JSON NOT NULL,
                        erros JSON NULL,
                        resultadoJson JSON NOT NULL,
                        iniciadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        finalizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        KEY execucoes_consolidacao_os_idx (os),
                        KEY execucoes_consolidacao_ordemServicoId_idx (ordemServicoId),
                        KEY execucoes_consolidacao_status_idx (statusConsolidacao),
                        CONSTRAINT execucoes_consolidacao_ordemServicoId_fkey
                            FOREIGN KEY (ordemServicoId) REFERENCES ordens_servico(id)
                            ON DELETE SET NULL ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS portais_senhas (
                        id INT NOT NULL AUTO_INCREMENT,
                        empresaId INT NULL,
                        seguradoraId INT NULL,
                        segmento VARCHAR(80) NULL,
                        empresaNome VARCHAR(180) NULL,
                        cnpj VARCHAR(14) NULL,
                        portalNome VARCHAR(120) NOT NULL,
                        portalUrl VARCHAR(255) NULL,
                        usuario VARCHAR(180) NOT NULL,
                        senhaCriptografada TEXT NOT NULL,
                        senhaIv VARCHAR(32) NOT NULL,
                        senhaTag VARCHAR(32) NOT NULL,
                        observacao TEXT NULL,
                        ativo TINYINT(1) NOT NULL DEFAULT 1,
                        criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        KEY portais_senhas_empresaId_idx (empresaId),
                        KEY portais_senhas_seguradoraId_idx (seguradoraId),
                        KEY portais_senhas_portalNome_idx (portalNome),
                        KEY portais_senhas_empresa_seguradora_idx (empresaId, seguradoraId),
                        CONSTRAINT portais_senhas_empresaId_fkey
                            FOREIGN KEY (empresaId) REFERENCES empresas(id)
                            ON DELETE SET NULL ON UPDATE CASCADE,
                        CONSTRAINT portais_senhas_seguradoraId_fkey
                            FOREIGN KEY (seguradoraId) REFERENCES seguradoras(id)
                            ON DELETE SET NULL ON UPDATE CASCADE
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()
                self._ensure_column(cursor, "portais_senhas", "empresaId", "INT NULL")
                self._ensure_column(cursor, "portais_senhas", "segmento", "VARCHAR(80) NULL")
                self._ensure_column(cursor, "portais_senhas", "empresaNome", "VARCHAR(180) NULL")
                self._ensure_column(cursor, "portais_senhas", "cnpj", "VARCHAR(14) NULL")
                self._ensure_index(cursor, "portais_senhas", "portais_senhas_empresaId_idx", "empresaId")
                self._ensure_index(cursor, "portais_senhas", "portais_senhas_empresa_seguradora_idx", "empresaId, seguradoraId")
                cursor.execute(
                    """
                    CREATE TABLE IF NOT EXISTS processamento_jobs (
                        id CHAR(36) NOT NULL,
                        tipo VARCHAR(80) NOT NULL,
                        status VARCHAR(40) NOT NULL,
                        parametros JSON NULL,
                        resultado JSON NULL,
                        erro TEXT NULL,
                        iniciadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
                        finalizadoEm DATETIME NULL,
                        atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                        PRIMARY KEY (id),
                        KEY processamento_jobs_tipo_status_idx (tipo, status),
                        KEY processamento_jobs_atualizadoEm_idx (atualizadoEm)
                    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                    """
                )
                conn.commit()

    def _ensure_column(self, cursor, table: str, column: str, definition: str) -> None:
        try:
            cursor.execute(f"ALTER TABLE {table} ADD COLUMN {column} {definition}")
        except Exception as exc:
            if "Duplicate column" not in str(exc) and "1060" not in str(exc):
                raise

    def _ensure_index(self, cursor, table: str, index_name: str, column: str) -> None:
        try:
            cursor.execute(f"ALTER TABLE {table} ADD INDEX {index_name} ({column})")
        except Exception as exc:
            if "Duplicate key name" not in str(exc) and "1061" not in str(exc):
                raise

    def salvar(self, resultado: ResultadoConsolidacao) -> None:
        if not resultado.os:
            return

        payload = resultado.to_dict()
        dados_conference = payload.get("dados_conference") or {}
        dados_extraidos = payload.get("dados_extraidos") or {}
        validacoes = payload.get("validacoes") or {}
        execucao_id = str(uuid.uuid4())
        gates_validacao = _validation_gates(validacoes, dados_conference, dados_extraidos)

        with self._connect() as conn:
            with conn.cursor() as cursor:
                if dados_conference:
                    cursor.execute(
                        """
                        INSERT INTO ordens_servico (
                            numero,
                            seguradora,
                            statusAtual,
                            dadosApi,
                            criadoEm,
                            atualizadoEm
                        )
                        VALUES (%s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                        ON DUPLICATE KEY UPDATE
                            seguradora = VALUES(seguradora),
                            statusAtual = VALUES(statusAtual),
                            dadosApi = VALUES(dadosApi),
                            atualizadoEm = CURRENT_TIMESTAMP
                        """,
                        (
                            resultado.os,
                            resultado.seguradora,
                            _to_str(dados_conference.get("status")),
                            _json(dados_conference),
                        ),
                    )
                cursor.execute("SELECT id FROM ordens_servico WHERE numero = %s", (resultado.os,))
                ordem = cursor.fetchone()
                ordem_id = ordem[0] if ordem else None

                cursor.execute(
                    """
                    INSERT INTO consolidacoes (
                        ordemServicoId,
                        os,
                        seguradora,
                        statusConsolidacao,
                        acaoSugerida,
                        execucaoId,
                        gatesValidacao,
                        dadosConference,
                        dadosExtraidos,
                        validacoes,
                        erros,
                        resultadoJson,
                        criadoEm,
                        atualizadoEm
                    )
                    VALUES (
                        %s, %s, %s, %s, %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        CURRENT_TIMESTAMP,
                        CURRENT_TIMESTAMP
                    )
                    ON DUPLICATE KEY UPDATE
                        ordemServicoId = VALUES(ordemServicoId),
                        seguradora = VALUES(seguradora),
                        statusConsolidacao = VALUES(statusConsolidacao),
                        acaoSugerida = VALUES(acaoSugerida),
                        execucaoId = VALUES(execucaoId),
                        gatesValidacao = VALUES(gatesValidacao),
                        dadosConference = VALUES(dadosConference),
                        dadosExtraidos = VALUES(dadosExtraidos),
                        validacoes = VALUES(validacoes),
                        erros = VALUES(erros),
                        resultadoJson = VALUES(resultadoJson),
                        curadorAprovado = 0,
                        curadorAprovadoEm = NULL,
                        curadorResponsavel = NULL,
                        atualizadoEm = CURRENT_TIMESTAMP
                    """,
                    (
                        ordem_id,
                        resultado.os,
                        resultado.seguradora,
                        resultado.status_consolidacao,
                        resultado.acao_sugerida,
                        execucao_id,
                        _json(gates_validacao),
                        _json(payload.get("dados_conference")),
                        _json(dados_extraidos),
                        _json(validacoes),
                        _json(payload.get("erros")),
                        _json(payload),
                    ),
                )
                cursor.execute(
                    """
                    INSERT INTO execucoes_consolidacao (
                        id,
                        ordemServicoId,
                        os,
                        seguradora,
                        statusConsolidacao,
                        acaoSugerida,
                        gatesValidacao,
                        dadosConference,
                        dadosExtraidos,
                        validacoes,
                        erros,
                        resultadoJson
                    )
                    VALUES (
                        %s, %s, %s, %s, %s, %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s,
                        %s
                    )
                    """,
                    (
                        execucao_id,
                        ordem_id,
                        resultado.os,
                        resultado.seguradora,
                        resultado.status_consolidacao,
                        resultado.acao_sugerida,
                        _json(gates_validacao),
                        _json(payload.get("dados_conference")),
                        _json(dados_extraidos),
                        _json(validacoes),
                        _json(payload.get("erros")),
                        _json(payload),
                    ),
                )
                conn.commit()

    def salvar_lote(self, resultados: Iterable[ResultadoConsolidacao]) -> None:
        for resultado in resultados:
            self.salvar(resultado)

    def sincronizar_snapshot_conference(self, registro: dict) -> None:
        codigo = _to_str(_first_value(registro, ["codigo", "os", "ordem_servico", "numero_os"]))
        if not codigo:
            return

        snapshot = _conference_snapshot_from_registro(registro, codigo)
        financeiro = {
            "financeiro_conference": {
                "valor_pecas": snapshot.get("valor_pecas"),
                "valor_servicos": snapshot.get("valor_servicos"),
                "valor_franquia": snapshot.get("valor_franquia"),
                "valor_total": snapshot.get("valor_total"),
            }
        }

        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO ordens_servico (
                        numero,
                        seguradora,
                        statusAtual,
                        dadosApi,
                        criadoEm,
                        atualizadoEm
                    )
                    VALUES (%s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    ON DUPLICATE KEY UPDATE
                        seguradora = VALUES(seguradora),
                        statusAtual = VALUES(statusAtual),
                        dadosApi = VALUES(dadosApi),
                        atualizadoEm = CURRENT_TIMESTAMP
                    """,
                    (
                        codigo,
                        snapshot.get("seguradora") or "",
                        _to_str(snapshot.get("status")),
                        _json(snapshot),
                    ),
                )
                cursor.execute(
                    """
                    SELECT dadosExtraidos, dadosConference, statusConsolidacao
                    FROM consolidacoes
                    WHERE os = %s
                    LIMIT 1
                    """,
                    (codigo,),
                )
                row = cursor.fetchone()
                dados_extraidos = _load_json(row[0]) if row else {}
                dados_conference_atual = _load_json(row[1]) if row else {}
                cursor.execute("SELECT id FROM ordens_servico WHERE numero = %s", (codigo,))
                ordem = cursor.fetchone()
                ordem_id = ordem[0] if ordem else None
                reaberta_conference = bool(
                    row
                    and (
                        row[2] == "ENCERRADO_MANUALMENTE"
                        or _encerrado_manualmente(dados_conference_atual)
                    )
                )
                dados_extraidos = dados_extraidos or {}
                dados_extraidos.update(financeiro)
                reaberta_flag = 1 if reaberta_conference else 0

                if reaberta_conference:
                    cursor.execute("DELETE FROM decisoes_humanas WHERE os = %s", (codigo,))
                    cursor.execute(
                        """
                        DELETE FROM fechamentos
                        WHERE os = %s
                          AND statusFechamento = 'ENCERRADO_MANUALMENTE'
                        """,
                        (codigo,),
                    )

                resultado_json = {
                    "os": codigo,
                    "seguradora": snapshot.get("seguradora") or "",
                    "status_consolidacao": "NAO_PROCESSADO",
                    "acao_sugerida": "AGUARDANDO_PASSO_1",
                    "validacoes": {},
                    "dados_conference": snapshot,
                    "dados_extraidos": dados_extraidos,
                    "erros": [],
                }
                cursor.execute(
                    """
                    INSERT INTO consolidacoes (
                        ordemServicoId,
                        os,
                        seguradora,
                        statusConsolidacao,
                        acaoSugerida,
                        gatesValidacao,
                        dadosConference,
                        dadosExtraidos,
                        validacoes,
                        erros,
                        resultadoJson,
                        ativoConferencia,
                        sincronizadoEm,
                        criadoEm,
                        atualizadoEm
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                    ON DUPLICATE KEY UPDATE
                        ordemServicoId = VALUES(ordemServicoId),
                        seguradora = VALUES(seguradora),
	                        statusConsolidacao = VALUES(statusConsolidacao),
	                        acaoSugerida = VALUES(acaoSugerida),
	                        gatesValidacao = VALUES(gatesValidacao),
	                        dadosConference = VALUES(dadosConference),
	                        dadosExtraidos = VALUES(dadosExtraidos),
	                        validacoes = VALUES(validacoes),
	                        erros = VALUES(erros),
	                        resultadoJson = VALUES(resultadoJson),
	                        curadorAprovado = 0,
	                        curadorAprovadoEm = NULL,
	                        curadorResponsavel = NULL,
                        ativoConferencia = 1,
                        sincronizadoEm = CURRENT_TIMESTAMP,
                        atualizadoEm = CURRENT_TIMESTAMP
                    """,
                    (
                        ordem_id,
                        codigo,
                        snapshot.get("seguradora") or "",
                        "NAO_PROCESSADO",
                        "AGUARDANDO_PASSO_1",
                        _json({}),
                        _json(snapshot),
                        _json(dados_extraidos),
                        _json({}),
                        _json([]),
                        _json(resultado_json),
                    ),
                )
                cursor.execute(
                    """
                    SELECT statusConsolidacao, acaoSugerida
                    FROM consolidacoes
                    WHERE os = %s
                    LIMIT 1
                    """,
                    (codigo,),
                )
                status_row = cursor.fetchone()
                status = status_row[0] if status_row else None
                acao = status_row[1] if status_row else None
                print(
                    f"SYNC_BASE consolidacoes upsert os={codigo} status={status} acao={acao}",
                    flush=True,
                )
                logger.info(
                    "SYNC_BASE consolidacoes upsert os=%s status=%s acao=%s",
                    codigo,
                    status,
                    acao,
                )
                conn.commit()

    def listar_snapshots_conference(self, status: int | str | None = 5, empresa: int | str | None = None) -> list[dict]:
        where = []
        params = []
        if status not in (None, ""):
            where.append("statusAtual = %s")
            params.append(_to_str(status))
        if empresa not in (None, ""):
            where.append(
                """
                (
                    JSON_UNQUOTE(JSON_EXTRACT(dadosApi, '$.empresa')) = %s
                    OR JSON_UNQUOTE(JSON_EXTRACT(dadosApi, '$.empresa_erp')) = %s
                )
                """
            )
            params.extend([_to_str(empresa), _to_str(empresa)])

        sql = """
            SELECT numero, seguradora, statusAtual, dadosApi
            FROM ordens_servico
        """
        if where:
            sql += " WHERE " + " AND ".join(where)
        sql += " ORDER BY atualizadoEm DESC, numero DESC"

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(sql, tuple(params))
                rows = cursor.fetchall()

        snapshots = []
        for row in rows:
            snapshot = _load_json(row.get("dadosApi")) or {}
            if snapshot:
                snapshots.append(snapshot)
        return snapshots

    def listar_snapshots_consolidacoes(self, status: int | str | None = 5, empresa: int | str | None = None) -> list[dict]:
        where = [
            "COALESCE(c.dadosConference, o.dadosApi) IS NOT NULL",
            "COALESCE(c.ativoConferencia, 1) = 1",
            "COALESCE(c.curadorAprovado, 0) = 0",
            "c.statusConsolidacao = 'NAO_PROCESSADO'",
            """
            COALESCE(
                JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.status')),
                JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.raw.status')),
                o.statusAtual,
                ''
            ) <> 'ENCERRADO_MANUALMENTE'
            """,
        ]
        params = []
        if status not in (None, ""):
            where.append(
                """
                COALESCE(
                    JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.status')),
                    JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.raw.status')),
                    o.statusAtual
                ) = %s
                """
            )
            params.append(_to_str(status))
        if empresa not in (None, ""):
            where.append(
                """
                (
                    JSON_UNQUOTE(JSON_EXTRACT(COALESCE(c.dadosConference, o.dadosApi), '$.empresa')) = %s
                    OR JSON_UNQUOTE(JSON_EXTRACT(COALESCE(c.dadosConference, o.dadosApi), '$.empresa_erp')) = %s
                )
                """
            )
            params.extend([_to_str(empresa), _to_str(empresa)])

        sql = f"""
            SELECT
                c.os,
                COALESCE(c.dadosConference, o.dadosApi) AS snapshot
            FROM consolidacoes c
            LEFT JOIN ordens_servico o
                ON o.numero = c.os
            WHERE {" AND ".join(where)}
            ORDER BY c.atualizadoEm DESC, c.os DESC
        """

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(sql, tuple(params))
                rows = cursor.fetchall()

        snapshots = []
        for row in rows:
            snapshot = _load_json(row.get("snapshot")) or {}
            if snapshot:
                snapshots.append(snapshot)
        return snapshots

    def buscar_snapshot_conference(self, codigo: str) -> dict:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT dadosApi
                    FROM ordens_servico
                    WHERE numero = %s
                    LIMIT 1
                    """,
                    (_to_str(codigo),),
                )
                row = cursor.fetchone()
        return _load_json(row.get("dadosApi")) if row else {}

    def remover_consolidacoes_fora_retrieve(
        self,
        codigos_ativos: Iterable[str],
        empresa: int | str | None = None,
    ) -> int:
        ativos = sorted({str(codigo) for codigo in codigos_ativos if codigo not in (None, "")})
        total = 0

        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_sync_consolidacoes_ativas (
                        os VARCHAR(50) NOT NULL,
                        PRIMARY KEY (os)
                    ) ENGINE=MEMORY
                    """
                )
                cursor.execute("TRUNCATE TABLE tmp_sync_consolidacoes_ativas")
                if ativos:
                    cursor.executemany(
                        "INSERT IGNORE INTO tmp_sync_consolidacoes_ativas (os) VALUES (%s)",
                        [(codigo,) for codigo in ativos],
                    )

                where_empresa = ""
                params = []
                if empresa not in (None, ""):
                    where_empresa = """
                      AND (
                        JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa')) = %s
                        OR JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa_erp')) = %s
                      )
                    """
                    params.extend([_to_str(empresa), _to_str(empresa)])

                cursor.execute(
                    f"""
                    UPDATE consolidacoes c
                    LEFT JOIN tmp_sync_consolidacoes_ativas a
                        ON a.os = c.os
                    SET
                        c.ativoConferencia = 0,
                        c.atualizadoEm = CURRENT_TIMESTAMP
                    WHERE a.os IS NULL
                      AND COALESCE(c.ativoConferencia, 1) = 1
                    {where_empresa}
                    """,
                    tuple(params),
                )
                total = cursor.rowcount
                conn.commit()

        print(
            f"SYNC_BASE consolidacoes reconciliadas ativos={len(ativos)} inativadas={total} empresa={empresa}",
            flush=True,
        )
        logger.info(
            "SYNC_BASE consolidacoes reconciliadas ativos=%s inativadas=%s empresa=%s",
            len(ativos),
            total,
            empresa,
        )
        return total

    def marcar_encerradas_fora_status(
        self,
        codigos_ativos: Iterable[str],
        data_inicial: str | None = None,
        data_final: str | None = None,
    ) -> int:
        ativos = {str(codigo) for codigo in codigos_ativos if codigo not in (None, "")}
        if not ativos:
            return 0

        total = 0

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT
                        c.os,
                        c.dadosConference,
                        c.curadorAprovado,
                        d.decisao AS decisaoHumana,
                        f.id AS fechamentoFinalId
                    FROM consolidacoes c
                    LEFT JOIN (
                        SELECT d1.*
                        FROM decisoes_humanas d1
                        INNER JOIN (
                            SELECT os, MAX(criadoEm) AS criadoEm
                            FROM decisoes_humanas
                            GROUP BY os
                        ) ult
                            ON ult.os = d1.os
                           AND ult.criadoEm = d1.criadoEm
                    ) d ON d.os = c.os
                    LEFT JOIN fechamentos f
                        ON f.os = c.os
                       AND f.statusFechamento IN (
                           'FECHADA_APROVADA',
                           'FECHADA_REPROVADA_RETORNO_OFICINA',
                           'FECHADA_ANALISE_MANUAL'
                       )
                    WHERE c.dadosConference IS NOT NULL
                    """
                )
                rows = cursor.fetchall()

                for row in rows:
                    codigo = str(row.get("os") or "")
                    if not codigo or codigo in ativos:
                        continue

                    dados_conference = _load_json(row.get("dadosConference")) or {}
                    if _conference_status(dados_conference) != "5":
                        continue
                    if not _registro_dentro_periodo(dados_conference, data_inicial, data_final):
                        continue

                    if row.get("fechamentoFinalId"):
                        continue

                    cursor.execute(
                        """
                        DELETE FROM fechamentos
                        WHERE os = %s
                          AND statusFechamento = 'ENCERRADO_MANUALMENTE'
                        """,
                        (codigo,),
                    )

                    raw = dict(dados_conference.get("raw") or {})
                    raw["status_anterior"] = raw.get("status") or dados_conference.get("status")
                    raw["status"] = "ENCERRADO_MANUALMENTE"
                    raw["status_inferido"] = True
                    dados_conference["status_anterior"] = dados_conference.get("status")
                    dados_conference["status"] = "ENCERRADO_MANUALMENTE"
                    dados_conference["status_inferido"] = True
                    dados_conference["raw"] = raw

                    cursor.execute(
                        """
                        UPDATE consolidacoes
                        SET
                            statusConsolidacao = 'ENCERRADO_MANUALMENTE',
                            acaoSugerida = 'ENCERRADO_MANUALMENTE',
                            dadosConference = %s,
                            curadorAprovado = 0,
                            curadorAprovadoEm = NULL,
                            curadorResponsavel = NULL,
                            atualizadoEm = CURRENT_TIMESTAMP
                        WHERE os = %s
                        """,
                        (_json(dados_conference), codigo),
                    )
                    total += cursor.rowcount

                    if bool(row.get("curadorAprovado")) or row.get("decisaoHumana") == "VOLTAR_OS":
                        cursor.execute("DELETE FROM decisoes_humanas WHERE os = %s", (codigo,))

                conn.commit()

        return total

    def buscar_dados_extraidos_por_os(self, os_number: str) -> dict:
        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT dadosExtraidos
                    FROM consolidacoes
                    WHERE os = %s
                    LIMIT 1
                    """,
                    (os_number,),
                )
                row = cursor.fetchone()

        if not row:
            return {}
        return _load_json(row[0]) or {}

    def contar_execucoes_status(self, os_number: str, status: str) -> int:
        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT COUNT(*) AS total
                    FROM execucoes_consolidacao
                    WHERE os = %s
                      AND statusConsolidacao = %s
                    """,
                    (os_number, status),
                )
                row = cursor.fetchone()

        return int(row[0] if row else 0)

    def buscar_por_os(self, os_number: str) -> ResultadoConsolidacao | None:
        with self._connect() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT resultadoJson, curadorAprovado
                    FROM consolidacoes
                    WHERE os = %s
                    LIMIT 1
                    """,
                    (os_number,),
                )
                row = cursor.fetchone()

        if not row:
            return None
        if not bool(row[1]):
            return None

        payload = _load_json(row[0])
        if not payload:
            return None

        return _resultado_from_dict(payload)

    def criar_job_processamento(self, tipo: str, parametros: dict) -> dict:
        job_id = str(uuid.uuid4())
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    INSERT INTO processamento_jobs (
                        id,
                        tipo,
                        status,
                        parametros
                    )
                    VALUES (%s, %s, 'PENDENTE', %s)
                    """,
                    (job_id, tipo, _json(parametros)),
                )
                conn.commit()

        return self.buscar_job_processamento(job_id) or {"id": job_id, "tipo": tipo, "status": "PENDENTE"}

    def buscar_job_ativo(self, tipo: str) -> dict | None:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT *
                    FROM processamento_jobs
                    WHERE tipo = %s
                      AND status IN ('PENDENTE', 'RODANDO', 'CANCELANDO')
                    ORDER BY iniciadoEm DESC
                    LIMIT 1
                    """,
                    (tipo,),
                )
                row = cursor.fetchone()

        return _job_from_row(row)

    def buscar_job_processamento(self, job_id: str) -> dict | None:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT *
                    FROM processamento_jobs
                    WHERE id = %s
                    LIMIT 1
                    """,
                    (job_id,),
                )
                row = cursor.fetchone()

        return _job_from_row(row)

    def job_cancelamento_solicitado(self, job_id: str) -> bool:
        job = self.buscar_job_processamento(job_id)
        return bool(job and job.get("status") == "CANCELANDO")

    def cancelar_job_processamento(self, job_id: str) -> dict | None:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    UPDATE processamento_jobs
                    SET
                        status = CASE
                            WHEN status IN ('PENDENTE', 'RODANDO') THEN 'CANCELANDO'
                            ELSE status
                        END,
                        erro = CASE
                            WHEN status IN ('PENDENTE', 'RODANDO') THEN 'Cancelamento solicitado.'
                            ELSE erro
                        END,
                        atualizadoEm = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (job_id,),
                )
                conn.commit()

        return self.buscar_job_processamento(job_id)

    def atualizar_job_processamento(
        self,
        job_id: str,
        status: str,
        resultado: dict | list | None = None,
        erro: str | None = None,
        finalizar: bool = False,
    ) -> dict | None:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    UPDATE processamento_jobs
                    SET
                        status = %s,
                        resultado = COALESCE(%s, resultado),
                        erro = %s,
                        finalizadoEm = CASE WHEN %s THEN CURRENT_TIMESTAMP ELSE finalizadoEm END,
                        atualizadoEm = CURRENT_TIMESTAMP
                    WHERE id = %s
                    """,
                    (
                        status,
                        _json(resultado) if resultado is not None else None,
                        erro,
                        1 if finalizar else 0,
                        job_id,
                    ),
                )
                conn.commit()

        return self.buscar_job_processamento(job_id)

    def salvar_empresas(self, empresas: Iterable[dict]) -> int:
        return self._salvar_cadastros("empresas", empresas)

    def salvar_seguradoras(self, seguradoras: Iterable[dict]) -> int:
        return self._salvar_cadastros("seguradoras", seguradoras)

    def _salvar_cadastros(self, tabela: str, registros: Iterable[dict]) -> int:
        total = 0
        with self._connect() as conn:
            with conn.cursor() as cursor:
                for registro in registros:
                    codigo = _first_value(
                        registro,
                        ["codigo", "id", "empresa", "empresa_codigo", "seguradora_codigo"],
                    )
                    if codigo in (None, ""):
                        continue

                    nome = _first_value(
                        registro,
                        ["nome", "razao_social", "razao", "descricao", "fantasia", "apelido"],
                    )
                    cnpj = _normalizar_cnpj(
                        _first_value(registro, ["cnpj", "cnpj_empresa", "seguradora_cnpj", "cpf_cnpj"])
                    )

                    if tabela == "empresas":
                        cursor.execute(
                            """
                            INSERT INTO empresas (
                                codigo,
                                nome,
                                cnpj,
                                dadosApi
                            )
                            VALUES (%s, %s, %s, %s)
                            ON DUPLICATE KEY UPDATE
                                nome = VALUES(nome),
                                cnpj = VALUES(cnpj),
                                dadosApi = VALUES(dadosApi),
                                atualizadoEm = CURRENT_TIMESTAMP
                            """,
                            (
                                str(codigo),
                                _to_str(nome),
                                cnpj,
                                _json(registro),
                            ),
                        )
                    else:
                        cursor.execute(
                            f"""
                            INSERT INTO {tabela} (
                                codigo,
                                nome,
                                cnpj,
                                dadosApi
                            )
                            VALUES (%s, %s, %s, %s)
                            ON DUPLICATE KEY UPDATE
                                nome = VALUES(nome),
                                cnpj = VALUES(cnpj),
                                dadosApi = VALUES(dadosApi),
                                atualizadoEm = CURRENT_TIMESTAMP
                            """,
                            (
                                str(codigo),
                                _to_str(nome),
                                cnpj,
                                _json(registro),
                            ),
                        )
                    total += 1
                conn.commit()

        return total

    def sincronizar_regras_cnpj(self, regras: Iterable[dict]) -> dict:
        resumo = {
            "regras_recebidas": 0,
            "regras_salvas": 0,
            "seguradoras_cnpj_salvas": 0,
            "empresas_nao_encontradas": [],
            "seguradoras_nao_encontradas": [],
        }
        seguradoras_cnpj_salvas = set()
        empresas_nao_encontradas = set()
        seguradoras_nao_encontradas = set()

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                for regra in regras:
                    resumo["regras_recebidas"] += 1
                    cnpj_empresa = _normalizar_cnpj(regra.get("CNPJ_Grupo"))
                    cnpj_seguradora = _normalizar_cnpj(regra.get("CNPJ_Seguradora"))
                    grupo = _to_str(regra.get("grupo"))
                    if not cnpj_empresa or not cnpj_seguradora or not grupo:
                        continue

                    empresa = self._buscar_empresa_por_cnpj(cursor, cnpj_empresa)
                    if not empresa:
                        empresas_nao_encontradas.add(cnpj_empresa)
                        continue

                    seguradora = self._buscar_seguradora(cursor, nome=grupo)
                    if not seguradora:
                        seguradoras_nao_encontradas.add(grupo)
                        continue

                    cursor.execute(
                        """
                        INSERT INTO seguradoras_cnpj (
                            seguradoraId,
                            cnpj,
                            grupo,
                            dadosApi
                        )
                        VALUES (%s, %s, %s, %s)
                        ON DUPLICATE KEY UPDATE
                            grupo = VALUES(grupo),
                            dadosApi = VALUES(dadosApi),
                            atualizadoEm = CURRENT_TIMESTAMP
                        """,
                        (seguradora["id"], cnpj_seguradora, grupo, _json(regra)),
                    )
                    cursor.execute(
                        """
                        SELECT id
                        FROM seguradoras_cnpj
                        WHERE seguradoraId = %s AND cnpj = %s
                        LIMIT 1
                        """,
                        (seguradora["id"], cnpj_seguradora),
                    )
                    seguradora_cnpj = cursor.fetchone()
                    if not seguradora_cnpj:
                        continue
                    seguradoras_cnpj_salvas.add(seguradora_cnpj["id"])

                    cursor.execute(
                        """
                        INSERT INTO empresa_seguradora_cnpj (
                            empresaId,
                            seguradoraCnpjId,
                            ativo,
                            dadosApi
                        )
                        VALUES (%s, %s, 1, %s)
                        ON DUPLICATE KEY UPDATE
                            ativo = 1,
                            dadosApi = VALUES(dadosApi),
                            atualizadoEm = CURRENT_TIMESTAMP
                        """,
                        (empresa["id"], seguradora_cnpj["id"], _json(regra)),
                    )
                    resumo["regras_salvas"] += 1
                conn.commit()

        resumo["seguradoras_cnpj_salvas"] = len(seguradoras_cnpj_salvas)
        resumo["empresas_nao_encontradas"] = sorted(empresas_nao_encontradas)
        resumo["seguradoras_nao_encontradas"] = sorted(seguradoras_nao_encontradas)
        return resumo

    def validar_cnpj_faturamento(
        self,
        empresa_codigo: str | None,
        seguradora_codigo: str | None,
        seguradora_nome: str | None,
        cnpj_empresa: str | None,
        cnpj_seguradora: str | None,
    ) -> ValidacaoResultado:
        cnpj_empresa_normalizado = _normalizar_cnpj(cnpj_empresa)
        cnpj_seguradora_normalizado = _normalizar_cnpj(cnpj_seguradora)

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                empresa = self._buscar_empresa(
                    cursor,
                    codigo=empresa_codigo,
                    cnpj=cnpj_empresa_normalizado,
                )
                if not cnpj_empresa_normalizado and empresa:
                    cnpj_empresa_normalizado = _normalizar_cnpj(empresa.get("cnpj"))

                if not empresa:
                    return ValidacaoResultado(
                        item="cnpj",
                        status=STATUS_PENDENTE,
                        mensagem="Empresa nao encontrada na base cadastral para validar CNPJ.",
                        dados={
                            "empresa": empresa_codigo,
                            "cnpj_empresa": cnpj_empresa_normalizado,
                        },
                    )

                if not cnpj_seguradora_normalizado:
                    return ValidacaoResultado(
                        item="cnpj",
                        status=STATUS_PENDENTE,
                        mensagem="CNPJ da seguradora nao foi retornado pela Conference.",
                        dados={
                            "empresa": empresa_codigo,
                            "cnpj_empresa": cnpj_empresa_normalizado,
                            "cnpj_seguradora": cnpj_seguradora_normalizado,
                        },
                    )

                seguradora = self._buscar_seguradora(
                    cursor,
                    codigo=seguradora_codigo,
                    nome=seguradora_nome,
                )
                if not seguradora:
                    return ValidacaoResultado(
                        item="cnpj",
                        status=STATUS_PENDENTE,
                        mensagem="Seguradora nao encontrada na base cadastral para validar CNPJ.",
                        dados={
                            "seguradora_codigo": seguradora_codigo,
                            "seguradora": seguradora_nome,
                            "cnpj_seguradora": cnpj_seguradora_normalizado,
                        },
                    )

                cnpjs_validos = self._listar_cnpjs_validos(cursor, empresa["id"], seguradora["id"])
                if cnpj_seguradora_normalizado not in cnpjs_validos:
                    mensagem = (
                        "CNPJ da seguradora nao confere com o vinculo empresa x seguradora cadastrado."
                        if cnpjs_validos
                        else "Empresa da OS nao possui CNPJ vinculado para a seguradora informada."
                    )
                    return ValidacaoResultado(
                        item="cnpj",
                        status=STATUS_REPROVADO,
                        mensagem=mensagem,
                        dados={
                            "empresa": empresa,
                            "seguradora": seguradora,
                            "cnpj_empresa": cnpj_empresa_normalizado,
                            "cnpj_seguradora": cnpj_seguradora_normalizado,
                            "cnpjs_validos": cnpjs_validos,
                        },
                    )

        return ValidacaoResultado(
            item="cnpj",
            status=STATUS_APROVADO,
            mensagem="CNPJ validado conforme vinculo empresa x seguradora.",
            dados={
                "empresa": empresa,
                "seguradora": seguradora,
                "cnpj_empresa": cnpj_empresa_normalizado,
                "cnpj_seguradora": cnpj_seguradora_normalizado,
                "cnpjs_validos": cnpjs_validos,
            },
        )

    def validar_cnpjs_ordens_servico(self, limit: int | None = None) -> dict:
        query = """
            SELECT os, seguradora, dadosConference, resultadoJson
            FROM consolidacoes
            WHERE dadosConference IS NOT NULL
            ORDER BY atualizadoEm DESC
        """
        params = []
        if limit:
            query += " LIMIT %s"
            params.append(int(limit))

        registros = []
        resumo = {
            "total": 0,
            "aprovados": 0,
            "reprovados": 0,
            "pendentes": 0,
            "erros": 0,
            "registros": registros,
        }

        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(query, params)
                rows = cursor.fetchall()

        for row in rows:
            resumo["total"] += 1
            try:
                dados = _load_json(row.get("dadosConference")) or {}
                resultado_json = _load_json(row.get("resultadoJson")) or {}
                dados_extraidos = resultado_json.get("dados_extraidos") or {}
                dados_orcamento = dados_extraidos.get("orcamento") or {}
                validacao = self._validar_cnpj_lote(dados, row.get("seguradora"), dados_orcamento)
                if validacao.status == STATUS_APROVADO:
                    resumo["aprovados"] += 1
                elif validacao.status == STATUS_REPROVADO:
                    resumo["reprovados"] += 1
                elif validacao.status == STATUS_PENDENTE:
                    resumo["pendentes"] += 1
                else:
                    resumo["erros"] += 1

                registros.append(
                    {
                        "os": row.get("os"),
                        "seguradora": dados.get("seguradora") or row.get("seguradora"),
                        "empresa": dados.get("empresa"),
                        "cnpj_empresa": dados.get("cnpj_empresa"),
                        "cnpj_seguradora": dados.get("cnpj_seguradora"),
                        "validacao": {
                            "status": validacao.status,
                            "mensagem": validacao.mensagem,
                            "dados": validacao.dados,
                        },
                    }
                )
            except Exception as exc:
                resumo["erros"] += 1
                registros.append(
                    {
                        "os": row.get("os"),
                        "seguradora": row.get("seguradora"),
                        "validacao": {
                            "status": "ERRO",
                            "mensagem": str(exc),
                            "dados": {},
                        },
                    }
                )

        return resumo

    def _validar_cnpj_lote(self, dados: dict, seguradora: str | None, dados_orcamento: dict):
        if _eh_bradesco(dados, seguradora):
            from core.models import DadosConference
            from services.validacoes.cnpj import validar_cnpj_bradesco_por_orcamento

            return validar_cnpj_bradesco_por_orcamento(
                DadosConference(
                    os=_to_str(dados.get("os") or dados.get("codigo")) or "",
                    seguradora=_to_str(dados.get("seguradora") or seguradora) or "",
                    codigo=_to_str(dados.get("codigo")),
                    empresa=_to_str(dados.get("empresa")),
                    seguradora_codigo=_to_str(dados.get("seguradora_codigo")),
                    cnpj_empresa=dados.get("cnpj_empresa"),
                    cnpj_seguradora=dados.get("cnpj_seguradora"),
                    raw=dados.get("raw") or {},
                ),
                dados_orcamento,
            )

        return self.validar_cnpj_faturamento(
            empresa_codigo=_to_str(dados.get("empresa")),
            seguradora_codigo=_to_str(dados.get("seguradora_codigo")),
            seguradora_nome=_to_str(dados.get("seguradora") or seguradora),
            cnpj_empresa=dados.get("cnpj_empresa"),
            cnpj_seguradora=dados.get("cnpj_seguradora"),
        )

    def dashboard_consolidacoes(self, limit: int = 500) -> dict:
        try:
            with self._connect() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute(
                        """
                        SELECT
                            c.id,
                            c.os,
                            c.seguradora,
                            c.statusConsolidacao,
                            c.acaoSugerida,
                            c.execucaoId,
                            c.gatesValidacao,
                            c.dadosConference,
                            c.dadosExtraidos,
                            c.validacoes,
                            c.resultadoJson,
                            e.nome AS empresaNome,
                            c.curadorAprovado,
                            c.curadorAprovadoEm,
                            c.curadorResponsavel,
                            (
                                SELECT COUNT(*)
                                FROM fechamentos f_retornos
                                WHERE f_retornos.os = c.os
                                  AND (
                                      f_retornos.decisao = 'RETORNAR_OFICINA'
                                      OR f_retornos.statusFechamento = 'FECHADA_REPROVADA_RETORNO_OFICINA'
                                  )
                            ) AS retornosOficina,
                            c.criadoEm,
                            c.atualizadoEm,
                            c.sincronizadoEm
                        FROM consolidacoes c
                        LEFT JOIN empresas e
                          ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
                        WHERE NOT EXISTS (
                            SELECT 1
                            FROM fechamentos f
                            WHERE f.os = c.os
                              AND f.statusFechamento IN (
	                                  'FECHADA_APROVADA',
	                                  'FECHADA_REPROVADA_RETORNO_OFICINA',
	                                  'FECHADA_ANALISE_MANUAL',
	                                  'ENCERRADO_MANUALMENTE',
	                                  'PENDENTE_PASSO_3'
	                              )
                              AND f.atualizadoEm >= c.atualizadoEm
                        )
                          AND COALESCE(c.ativoConferencia, 1) = 1
                        ORDER BY c.atualizadoEm DESC
                        LIMIT %s
                        """,
                        (int(limit),),
                    )
                    rows = cursor.fetchall()
        except Exception as exc:
            return _dashboard_error(exc, _empty_consolidacoes())

        by_status = {}
        by_action = {}
        by_seguradora = {}
        by_validation = {}
        timeline = {}
        items = []
        valor_total = 0.0
        aprovado_valor = 0.0
        pendente_valor = 0.0
        curador_aprovadas = 0
        nao_analisadas = 0
        ultima_leitura_conference = None

        for row in rows:
            sincronizado_em = row.get("sincronizadoEm")
            if sincronizado_em and (ultima_leitura_conference is None or sincronizado_em > ultima_leitura_conference):
                ultima_leitura_conference = sincronizado_em
            dados_conference = _load_json(row.get("dadosConference")) or {}
            dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}
            validacoes = _load_json(row.get("validacoes")) or {}
            gates_validacao = _load_json(row.get("gatesValidacao")) or _validation_gates(
                validacoes,
                dados_conference,
                dados_extraidos,
            )
            valor = _conference_value(row)
            complementar = _is_complementar(validacoes)
            batimento = None if complementar else _balance_difference(validacoes, gates_validacao)
            data = _date_key(row.get("atualizadoEm"))
            conference_status = _conference_status(dados_conference)
            encerrado_manualmente = _encerrado_manualmente(dados_conference)
            timeline_item = timeline.setdefault(
                data,
                {
                    "data": data,
                    "total": 0,
                    "valor": 0.0,
                    "aprovadas": 0,
                    "pendentes": 0,
                    "reprovadas": 0,
                },
            )
            timeline_item["total"] += 1
            timeline_item["valor"] = _currency(timeline_item["valor"] + valor)
            status = _normalizar_status_sem_nbs(row.get("statusConsolidacao") or "NAO_INFORMADO")
            if status == "APROVADA_CONSOLIDACAO":
                timeline_item["aprovadas"] += 1
                aprovado_valor = _currency(aprovado_valor + valor)
            elif status == "NAO_PROCESSADO":
                nao_analisadas += 1
            elif status.startswith("PENDENTE"):
                timeline_item["pendentes"] += 1
                pendente_valor = _currency(pendente_valor + valor)
            elif status.startswith("REPROVADA"):
                timeline_item["reprovadas"] += 1

            valor_total = _currency(valor_total + valor)
            if bool(row.get("curadorAprovado")):
                curador_aprovadas += 1
            retornos_oficina = _int_or_zero(row.get("retornosOficina"))
            status_efetivo = (
                "PENDENTE_COMPLEMENTO_MANUAL"
                if (
                    retornos_oficina > 3
                    and status not in ("APROVADA_CONSOLIDACAO", "PENDENTE_COMPLEMENTO_MANUAL")
                    and not _tem_ajuste_manual(dados_extraidos)
                )
                else status
            )
            status_operacional = "ENCERRADO_MANUALMENTE" if encerrado_manualmente else status_efetivo
            _increment(by_status, status_efetivo)
            _increment(by_action, row.get("acaoSugerida") or "NAO_INFORMADA")
            _increment(by_seguradora, row.get("seguradora") or "Nao informada")
            for name, validation in validacoes.items():
                if name == "sincronizacao_nbs":
                    continue
                _increment(by_validation, f"{name}:{(validation or {}).get('status') or 'NAO_INFORMADO'}")

            items.append(
                {
                    "id": row.get("id"),
                    "os": row.get("os"),
                    "codigoConference": row.get("os"),
                    "osObjeto": _display_os(dados_conference, row.get("os")),
                    "seguradora": row.get("seguradora"),
                    "empresa": dados_conference.get("empresa") or "",
                    "empresaNome": row.get("empresaNome") or "",
                    "chassi": dados_conference.get("chassi") or "",
                    "placa": dados_conference.get("placa") or "",
                    "valor": valor,
                    "batimento": batimento,
                    "batimentoLabel": "OS Complementar" if complementar else None,
                    "batimentoBusca": (
                        "os complementar complemento batimento manual"
                        if complementar
                        else _balance_search_text(batimento)
                    ),
                    "status": status_efetivo,
                    "statusConsolidacao": status_efetivo,
                    "statusOriginal": status,
                    "statusOperacional": status_operacional,
                    "encerradoManualmente": encerrado_manualmente,
                    "retornosOficina": retornos_oficina,
                    "conferenceStatus": conference_status,
                    "acao": row.get("acaoSugerida"),
                    "execucaoId": row.get("execucaoId"),
                    "gatesValidacao": gates_validacao,
                    "validacoes": validacoes,
                    "dadosConference": dados_conference,
                    "dadosExtraidos": dados_extraidos,
                    "curadoria": {
                        "aprovado": bool(row.get("curadorAprovado")),
                        "aprovadoEm": _iso(row.get("curadorAprovadoEm")),
                        "responsavel": row.get("curadorResponsavel"),
                    },
                    "criadoEm": _iso(row.get("criadoEm")),
                    "atualizadoEm": _iso(row.get("atualizadoEm")),
                }
            )

        reprovadas = sum(value for key, value in by_status.items() if str(key).startswith("REPROVADA"))
        return {
            "ok": True,
            "updatedAt": datetime.now().isoformat(timespec="seconds"),
            "ultimaLeituraConference": _iso(ultima_leitura_conference),
            "totals": {
                "total": len(rows),
                "aprovadas": by_status.get("APROVADA_CONSOLIDACAO", 0),
                "pendentes": by_status.get("PENDENTE_BATIMENTO_HUMANO", 0),
                "reprovadas": reprovadas,
                "erros": by_status.get("ERRO_TECNICO", 0)
                + by_status.get("FALHA_SINCRONIZACAO_NBS_FECHAR_MANUAL", 0),
                "naoAnalisadas": nao_analisadas,
                "curadorAprovadas": curador_aprovadas,
                "aguardandoCuradoria": max(len(rows) - curador_aprovadas, 0),
                "automaticos": 0,
                "valorTotal": valor_total,
                "aprovadoValor": aprovado_valor,
                "pendenteValor": pendente_valor,
            },
            "timeline": sorted(timeline.values(), key=lambda item: item["data"]),
            "byStatus": _entries(by_status),
            "byAction": _entries(by_action),
            "bySeguradora": _entries(by_seguradora, reverse=True)[:12],
            "byValidation": _entries(by_validation),
            "items": items,
        }

    def dashboard_execucoes(self, limit: int = 500) -> dict:
        try:
            with self._connect() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute(
                        """
                        SELECT
                            id,
                            os,
                            seguradora,
                            statusConsolidacao,
                            acaoSugerida,
                            gatesValidacao,
                            dadosConference,
                            dadosExtraidos,
                            validacoes,
                            erros,
                            iniciadoEm,
                            finalizadoEm
                        FROM execucoes_consolidacao
                        ORDER BY finalizadoEm DESC
                        LIMIT %s
                        """,
                        (int(limit),),
                    )
                    rows = cursor.fetchall()
        except Exception as exc:
            return _dashboard_error(exc, _empty_execucoes())

        by_status = {}
        by_action = {}
        timeline = {}
        items = []
        encerradas_manualmente = 0
        com_erro = 0

        for row in rows:
            dados_conference = _load_json(row.get("dadosConference")) or {}
            erros = _load_json(row.get("erros")) or {}
            status = _normalizar_status_sem_nbs(row.get("statusConsolidacao") or "NAO_INFORMADO")
            conference_status = _conference_status(dados_conference)
            encerrado_manualmente = _encerrado_manualmente(dados_conference)
            status_operacional = "ENCERRADO_MANUALMENTE" if encerrado_manualmente else status
            data = _date_key(row.get("finalizadoEm"))
            timeline_item = timeline.setdefault(
                data,
                {"data": data, "total": 0, "encerradasManualmente": 0, "erros": 0},
            )
            timeline_item["total"] += 1
            if encerrado_manualmente:
                timeline_item["encerradasManualmente"] += 1
                encerradas_manualmente += 1
            if "ERRO" in status or bool(erros):
                timeline_item["erros"] += 1
                com_erro += 1

            _increment(by_status, status_operacional)
            _increment(by_action, row.get("acaoSugerida") or "NAO_INFORMADA")
            items.append(
                {
                    "id": row.get("id"),
                    "codigoConference": row.get("os"),
                    "os": _display_os(dados_conference, row.get("os")),
                    "seguradora": row.get("seguradora"),
                    "empresa": dados_conference.get("empresa") or "",
                    "chassi": dados_conference.get("chassi") or "",
                    "placa": dados_conference.get("placa") or "",
                    "status": status,
                    "statusOperacional": status_operacional,
                    "encerradoManualmente": encerrado_manualmente,
                    "conferenceStatus": conference_status,
                    "acao": row.get("acaoSugerida"),
                    "gatesValidacao": _load_json(row.get("gatesValidacao")) or {},
                    "dadosConference": dados_conference,
                    "dadosExtraidos": _load_json(row.get("dadosExtraidos")) or {},
                    "validacoes": _load_json(row.get("validacoes")) or {},
                    "erros": erros,
                    "iniciadoEm": _iso(row.get("iniciadoEm")),
                    "finalizadoEm": _iso(row.get("finalizadoEm")),
                }
            )

        return {
            "ok": True,
            "updatedAt": datetime.now().isoformat(timespec="seconds"),
            "totals": {
                "total": len(rows),
                "encerradasManualmente": encerradas_manualmente,
                "comErro": com_erro,
            },
            "timeline": sorted(timeline.values(), key=lambda item: item["data"]),
            "byStatus": _entries(by_status),
            "byAction": _entries(by_action),
            "items": items,
        }

    def aprovar_consolidacao_curador(self, os_number: str, responsavel: str = "curador") -> dict:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    UPDATE consolidacoes
                    SET
                        curadorAprovado = 1,
                        curadorAprovadoEm = CURRENT_TIMESTAMP,
                        curadorResponsavel = %s,
                        atualizadoEm = CURRENT_TIMESTAMP
                    WHERE os = %s
                    """,
                    (responsavel, os_number),
                )
                conn.commit()

                if cursor.rowcount == 0:
                    return {"ok": False, "error": "OS nao encontrada para aprovacao.", "os": os_number}

                cursor.execute(
                    """
                    SELECT os, curadorAprovado, curadorAprovadoEm, curadorResponsavel
                    FROM consolidacoes
                    WHERE os = %s
                    LIMIT 1
                    """,
                    (os_number,),
                )
                row = cursor.fetchone() or {}

        return {
            "ok": True,
            "os": row.get("os") or os_number,
            "curadoria": {
                "aprovado": bool(row.get("curadorAprovado")),
                "aprovadoEm": _iso(row.get("curadorAprovadoEm")),
                "responsavel": row.get("curadorResponsavel"),
            },
        }

    def revisar_cnpj_tokio(self, os_number: str, aprovado: bool, responsavel: str = "curador") -> dict:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT
                        os,
                        seguradora,
                        dadosConference,
                        dadosExtraidos,
                        validacoes
                    FROM consolidacoes
                    WHERE os = %s
                      AND COALESCE(ativoConferencia, 1) = 1
                    LIMIT 1
                    """,
                    (os_number,),
                )
                row = cursor.fetchone()
                if not row:
                    return {"ok": False, "error": "OS nao encontrada para revisao de CNPJ.", "os": os_number}

                if not _normalizar_seguradora(row.get("seguradora") or "").startswith("tokio"):
                    return {"ok": False, "error": "Revisao manual de CNPJ permitida apenas para Tokio.", "os": os_number}

                dados_conference = _load_json(row.get("dadosConference")) or {}
                dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}
                validacoes = _load_json(row.get("validacoes")) or {}
                cnpj = _normalizar_cnpj(
                    dados_conference.get("cnpj_seguradora")
                    or (dados_conference.get("raw") or {}).get("cnpj_seguradora")
                    or (dados_conference.get("raw") or {}).get("seguradora_cnpj")
                    or ""
                )
                status_cnpj = STATUS_APROVADO if aprovado else STATUS_REPROVADO
                validacoes["cnpj"] = {
                    "item": "cnpj",
                    "status": status_cnpj,
                    "mensagem": (
                        f"CNPJ { _format_cnpj(cnpj) } aprovado manualmente pela curadoria."
                        if aprovado
                        else f"CNPJ { _format_cnpj(cnpj) } reprovado manualmente pela curadoria."
                    ),
                    "dados": {
                        "cnpj_seguradora": cnpj,
                        "decisao_manual": "APROVADO" if aprovado else "REPROVADO",
                        "responsavel": responsavel,
                        "seguradora": "Tokio",
                    },
                }
                status_consolidacao, acao_sugerida = classificar_consolidacao(
                    _validacoes_to_model(validacoes),
                    tentativas_valor_divergente=0,
                )
                ocorrencias = [
                    item
                    for item in (dados_extraidos.get("ocorrencias_passo3") or [])
                    if not (isinstance(item, dict) and item.get("origem") == "cnpj")
                ]
                ocorrencias.extend(_ocorrencias_cnpj_manual(cnpj, aprovado))
                dados_extraidos["ocorrencias_passo3"] = _dedupe_ocorrencias_dict(ocorrencias)
                if not aprovado:
                    status_consolidacao = CONSOLIDACAO_REPROVADA_CNPJ_INVALIDO
                    acao_sugerida = ACAO_ENVIAR_PASSO_2

                gates_validacao = _validation_gates(validacoes, dados_conference, dados_extraidos)
                cursor.execute(
                    """
                    UPDATE consolidacoes
                    SET
                        statusConsolidacao = %s,
                        acaoSugerida = %s,
                        gatesValidacao = %s,
                        dadosExtraidos = %s,
                        validacoes = %s,
                        curadorAprovado = 0,
                        curadorAprovadoEm = NULL,
                        curadorResponsavel = NULL,
                        atualizadoEm = CURRENT_TIMESTAMP
                    WHERE os = %s
                    """,
                    (
                        status_consolidacao,
                        acao_sugerida,
                        _json(gates_validacao),
                        _json(dados_extraidos),
                        _json(validacoes),
                        os_number,
                    ),
                )
                conn.commit()

        return {
            "ok": True,
            "os": os_number,
            "cnpj": {
                "aprovado": aprovado,
                "status": status_cnpj,
                "valor": cnpj,
            },
            "statusConsolidacao": status_consolidacao,
            "acaoSugerida": acao_sugerida,
        }

    def executar_passo2_curadoria_automatica(
        self,
        limit: int = 100,
        dry_run: bool = False,
        responsavel: str = "rpa",
        os_number: str | None = None,
    ) -> dict:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
	                    SELECT
	                        c.os,
	                        c.seguradora,
	                        c.statusConsolidacao,
	                        c.acaoSugerida,
	                        c.dadosConference,
	                        c.dadosExtraidos,
	                        c.validacoes,
                            (
                                SELECT COUNT(*)
                                FROM fechamentos f_retornos
                                WHERE f_retornos.os = c.os
                                  AND (
                                      f_retornos.decisao = 'RETORNAR_OFICINA'
                                      OR f_retornos.statusFechamento = 'FECHADA_REPROVADA_RETORNO_OFICINA'
                                  )
                            ) AS retornosOficina
	                    FROM consolidacoes c
	                    WHERE COALESCE(c.ativoConferencia, 1) = 1
	                      AND (%s IS NULL OR c.os = %s)
	                      AND c.statusConsolidacao <> 'ENCERRADO_MANUALMENTE'
	                      AND (
	                          c.statusConsolidacao = 'APROVADA_CONSOLIDACAO'
	                          OR c.acaoSugerida = 'RETORNAR_OFICINA'
	                          OR (
                              c.statusConsolidacao <> 'ERRO_TECNICO'
                              AND (
                                  c.statusConsolidacao LIKE 'REPROVADA%%'
                                  OR c.statusConsolidacao LIKE 'FALHA%%'
                                  OR c.statusConsolidacao LIKE 'ERRO%%'
                              )
                          )
                      )
	                      AND NOT EXISTS (
	                          SELECT 1
	                          FROM fechamentos f
	                          WHERE f.os = c.os
	                            AND f.statusFechamento = 'PENDENTE_PASSO_3'
	                            AND f.criadoEm >= c.atualizadoEm
	                      )
                    ORDER BY c.atualizadoEm ASC
                    LIMIT %s
                    """,
                    (os_number, os_number, int(limit)),
                )
                rows = cursor.fetchall()

                resultados = []
                for index, row in enumerate(rows, start=1):
                    os_number = _to_str(row.get("os"))
                    status = _to_str(row.get("statusConsolidacao"))
                    print(
                        f"PASSO2 OS {os_number} iniciando ({index}/{len(rows)}) status={status}",
                        flush=True,
                    )
                    logger.info("PASSO2 OS %s iniciando (%s/%s) status=%s", os_number, index, len(rows), status)

                    dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}

                    if _passo2_status_aprovado(status):
                        ocorrencias = _passo2_ocorrencias_aprovacao(row)
                        resultado = {
                            "ok": True,
                            "os": os_number,
                            "acao": "APROVAR",
                            "statusConsolidacao": status,
                            "dryRun": dry_run,
                        }
                        if not dry_run:
                            _inserir_fila_fechamento_passo2(
                                cursor,
                                os_number,
                                decisao="APROVAR",
                                status_consolidacao=status,
                                ocorrencias=ocorrencias,
                                responsavel=responsavel,
                                row=row,
                            )
                        resultados.append(resultado)
                        print(f"PASSO2 OS {os_number} enfileirada para aprovacao", flush=True)
                        logger.info("PASSO2 OS %s enfileirada para aprovacao", os_number)
                        continue

                    if _passo2_tokio_cnpj_pendente(row):
                        resultado = {
                            "ok": True,
                            "os": os_number,
                            "acao": "IGNORAR",
                            "statusConsolidacao": status,
                            "motivo": "Tokio com CNPJ pendente aguarda curadoria manual do CNPJ.",
                            "dryRun": dry_run,
                        }
                        resultados.append(resultado)
                        print(f"PASSO2 OS {os_number} ignorada Tokio com CNPJ pendente", flush=True)
                        logger.info("PASSO2 OS %s ignorada Tokio com CNPJ pendente", os_number)
                        continue

                    if not _passo2_status_vermelho(status) and row.get("acaoSugerida") != "RETORNAR_OFICINA":
                        resultado = {
                            "ok": True,
                            "os": os_number,
                            "acao": "IGNORAR",
                            "statusConsolidacao": status,
                            "motivo": "Status nao elegivel para curadoria automatica.",
                            "dryRun": dry_run,
                        }
                        resultados.append(resultado)
                        print(f"PASSO2 OS {os_number} ignorada status={status}", flush=True)
                        logger.info("PASSO2 OS %s ignorada status=%s", os_number, status)
                        continue

                    observacao = _passo2_observacao_reprovacao(status, dados_extraidos)
                    resultado = {
                        "ok": True,
                        "os": os_number,
                        "acao": "RETORNAR_OFICINA",
                        "statusConsolidacao": status,
                        "observacao": observacao,
                        "dryRun": dry_run,
                    }
                    if not dry_run:
                        _inserir_fila_fechamento_passo2(
                            cursor,
                            os_number,
                            decisao="RETORNAR_OFICINA",
                            status_consolidacao=status,
                            ocorrencias=[{"comentario": observacao}],
                            responsavel=responsavel,
                            row=row,
                        )
                        cursor.execute(
                            """
                            UPDATE consolidacoes
                            SET
                                acaoSugerida = 'RETORNAR_OFICINA',
                                atualizadoEm = CURRENT_TIMESTAMP
                            WHERE os = %s
                            """,
                            (os_number,),
                        )
                    resultados.append(resultado)
                    print(f"PASSO2 OS {os_number} reprovada automaticamente observacao={observacao}", flush=True)
                    logger.info("PASSO2 OS %s reprovada automaticamente observacao=%s", os_number, observacao)

                if dry_run:
                    conn.rollback()
                else:
                    conn.commit()

        por_acao = {}
        for resultado in resultados:
            acao = resultado.get("acao") or "NAO_INFORMADA"
            por_acao[acao] = por_acao.get(acao, 0) + 1

        print(f"PASSO2 curadoria automatica concluida total={len(resultados)} por_acao={por_acao}", flush=True)
        logger.info("PASSO2 curadoria automatica concluida total=%s por_acao=%s", len(resultados), por_acao)
        return {
            "ok": True,
            "dryRun": dry_run,
            "total": len(resultados),
            "porAcao": por_acao,
            "resultados": resultados,
        }

    def buscar_contexto_fechamento(self, os_number: str) -> dict | None:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT
                        os,
                        seguradora,
                        statusConsolidacao,
                        acaoSugerida,
                        dadosConference,
                        dadosExtraidos,
                        validacoes,
                        resultadoJson,
                        curadorAprovado
                    FROM consolidacoes
                    WHERE os = %s
                      AND COALESCE(ativoConferencia, 1) = 1
                      AND statusConsolidacao <> 'ENCERRADO_MANUALMENTE'
                      AND NOT EXISTS (
                          SELECT 1
                          FROM fechamentos f
                          WHERE f.os = consolidacoes.os
                            AND f.statusFechamento IN (
                                'FECHADA_APROVADA',
                                'FECHADA_REPROVADA_RETORNO_OFICINA',
                                'FECHADA_ANALISE_MANUAL',
                                'ENCERRADO_MANUALMENTE'
                            )
                            AND f.atualizadoEm >= consolidacoes.atualizadoEm
                      )
                    LIMIT 1
                    """,
                    (os_number,),
                )
                consolidacao = cursor.fetchone()
                if not consolidacao:
                    return None

                cursor.execute(
                    """
                    SELECT id, decisao, ocorrencias, respostaApi, criadoEm
                    FROM fechamentos
                    WHERE os = %s
                      AND statusFechamento = 'PENDENTE_PASSO_3'
                    ORDER BY criadoEm ASC
                    LIMIT 1
                    """,
                    (os_number,),
                )
                fila = cursor.fetchone()
                decisao = None
                if fila:
                    resposta_fila = _load_json(fila.get("respostaApi")) or {}
                    ocorrencias_fila = _filtrar_ocorrencias_desativadas(_load_json(fila.get("ocorrencias")) or [])
                    observacao = " ".join(
                        _to_str(item.get("comentario"))
                        for item in ocorrencias_fila
                        if isinstance(item, dict) and _to_str(item.get("comentario"))
                    )
                    decisao = {
                        "decisao": fila.get("decisao"),
                        "observacao": observacao,
                        "responsavel": resposta_fila.get("responsavel"),
                        "dadosDecisao": {
                            "origem": resposta_fila.get("origem"),
                            "fechamentoId": fila.get("id"),
                        },
                        "criadoEm": fila.get("criadoEm"),
                    }
                else:
                    cursor.execute(
                        """
                        SELECT decisao, observacao, responsavel, dadosDecisao, criadoEm
                        FROM decisoes_humanas
                        WHERE os = %s
                        ORDER BY criadoEm DESC
                        LIMIT 1
                        """,
                        (os_number,),
                    )
                    decisao = cursor.fetchone()

        return _normalizar_contexto_fechamento(consolidacao, decisao)

    def listar_fila_fechamento(self, limit: int = 100, automaticos: bool = False) -> list[dict]:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute(
                    """
                    SELECT
                        f.id AS fechamentoId,
                        c.os,
                        c.seguradora,
                        c.statusConsolidacao,
                        c.acaoSugerida,
                        c.dadosConference,
                        c.dadosExtraidos,
                        c.validacoes,
                        c.resultadoJson,
                        c.curadorAprovado,
                        f.decisao,
                        f.ocorrencias AS ocorrenciasFila,
                        f.respostaApi AS respostaFila,
                        f.criadoEm AS decisaoCriadoEm
                    FROM consolidacoes c
                    INNER JOIN fechamentos f
                        ON f.os = c.os
                       AND f.statusFechamento = 'PENDENTE_PASSO_3'
                       AND f.criadoEm >= c.atualizadoEm
	                    WHERE COALESCE(c.ativoConferencia, 1) = 1
                      AND c.statusConsolidacao <> 'ENCERRADO_MANUALMENTE'
                    ORDER BY f.criadoEm ASC
                    LIMIT %s
                    """,
                    (int(limit),),
                )
                rows = cursor.fetchall()

        contextos = []
        for row in rows:
            decisao = None
            if row.get("decisao"):
                resposta_fila = _load_json(row.get("respostaFila")) or {}
                ocorrencias_fila = _filtrar_ocorrencias_desativadas(_load_json(row.get("ocorrenciasFila")) or [])
                observacao = " ".join(
                    _to_str(item.get("comentario"))
                    for item in ocorrencias_fila
                    if isinstance(item, dict) and _to_str(item.get("comentario"))
                )
                decisao = {
                    "decisao": row.get("decisao"),
                    "observacao": observacao,
                    "responsavel": resposta_fila.get("responsavel"),
                    "dadosDecisao": {
                        "origem": resposta_fila.get("origem"),
                        "fechamentoId": row.get("fechamentoId"),
                    },
                    "criadoEm": row.get("decisaoCriadoEm"),
                }
            contextos.append(_normalizar_contexto_fechamento(row, decisao))
        return contextos

    def salvar_fechamento(
        self,
        os_number: str,
        decisao: str,
        status_fechamento: str,
        valor_aprovado=None,
        ocorrencias=None,
        anexos=None,
        resposta_api=None,
        erro: str | None = None,
        fechamento_id=None,
    ) -> dict:
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                if fechamento_id:
                    cursor.execute(
                        """
                        UPDATE fechamentos
                        SET
                            decisao = %s,
                            statusFechamento = %s,
                            valorAprovado = %s,
                            ocorrencias = %s,
                            anexos = %s,
                            respostaApi = %s,
                            erro = %s,
                            atualizadoEm = CURRENT_TIMESTAMP
                        WHERE id = %s
                          AND os = %s
                          AND statusFechamento = 'PENDENTE_PASSO_3'
                        """,
                        (
                            decisao,
                            status_fechamento,
                            valor_aprovado,
                            _json(ocorrencias or []),
                            _json(anexos or []),
                            _json(resposta_api or {}),
                            erro,
                            fechamento_id,
                            os_number,
                        ),
                    )
                    if cursor.rowcount == 0:
                        fechamento_id = None

                if not fechamento_id:
                    cursor.execute(
                        """
                        INSERT INTO fechamentos (
                            os,
                            decisao,
                            statusFechamento,
                            valorAprovado,
                            ocorrencias,
                            anexos,
                            respostaApi,
                            erro,
                            criadoEm,
                            atualizadoEm
                        )
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                        """,
                        (
                            os_number,
                            decisao,
                            status_fechamento,
                            valor_aprovado,
                            _json(ocorrencias or []),
                            _json(anexos or []),
                            _json(resposta_api or {}),
                            erro,
                        ),
                    )
                    fechamento_id = cursor.lastrowid
                conn.commit()

                cursor.execute(
                    """
                    SELECT id, os, decisao, statusFechamento, valorAprovado, erro
                    FROM fechamentos
                    WHERE id = %s
                    LIMIT 1
                    """,
                    (fechamento_id,),
                )
                row = cursor.fetchone() or {}

        return {
            "id": row.get("id"),
            "os": row.get("os") or os_number,
            "decisao": row.get("decisao") or decisao,
            "statusFechamento": row.get("statusFechamento") or status_fechamento,
            "valorAprovado": _currency(row.get("valorAprovado")),
            "erro": row.get("erro"),
        }

    def dashboard_fechamentos(self, limit: int = 500) -> dict:
        try:
            with self._connect() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute(
                        """
                        SELECT
                            fechamentos.id,
                            fechamentos.os,
                            fechamentos.decisao,
                            fechamentos.statusFechamento,
                            fechamentos.valorAprovado,
                            fechamentos.ocorrencias,
                            fechamentos.anexos,
                            fechamentos.respostaApi,
                            fechamentos.erro,
                            c.seguradora,
                            c.statusConsolidacao,
                            c.acaoSugerida,
                            c.dadosConference,
                            e.nome AS empresaNome,
                            fechamentos.criadoEm,
                            fechamentos.atualizadoEm
                        FROM fechamentos
                        LEFT JOIN consolidacoes c ON c.os = fechamentos.os
                        LEFT JOIN empresas e
                          ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
                        ORDER BY fechamentos.atualizadoEm DESC
                        LIMIT %s
                        """,
                        (int(limit),),
                    )
                    rows = cursor.fetchall()
        except Exception as exc:
            return _dashboard_error(exc, _empty_fechamentos())

        by_status = {}
        by_decision = {}
        timeline = {}
        items = []
        valor_aprovado = 0.0

        for row in rows:
            dados_conference = _load_json(row.get("dadosConference")) or {}
            valor = _currency(row.get("valorAprovado"))
            data = _date_key(row.get("atualizadoEm"))
            timeline_item = timeline.setdefault(
                data,
                {"data": data, "total": 0, "valor": 0.0, "fechados": 0, "erros": 0},
            )
            timeline_item["total"] += 1
            timeline_item["valor"] = _currency(timeline_item["valor"] + valor)
            status = row.get("statusFechamento") or "NAO_INFORMADO"
            if "ERRO" in status:
                timeline_item["erros"] += 1
            else:
                timeline_item["fechados"] += 1
            _increment(by_status, status)
            _increment(by_decision, row.get("decisao") or "NAO_INFORMADA")
            valor_aprovado = _currency(valor_aprovado + valor)
            items.append(
                {
                    "id": row.get("id"),
                    "os": row.get("os"),
                    "codigoConference": row.get("os"),
                    "osObjeto": _display_os(dados_conference, row.get("os")),
                    "seguradora": row.get("seguradora"),
                    "empresa": dados_conference.get("empresa") or "",
                    "empresaNome": row.get("empresaNome") or "",
                    "decisao": row.get("decisao"),
                    "status": status,
                    "statusConsolidacao": row.get("statusConsolidacao"),
                    "acao": row.get("acaoSugerida"),
                    "valorAprovado": valor,
                    "ocorrencias": _load_json(row.get("ocorrencias")) or {},
                    "anexos": _load_json(row.get("anexos")) or {},
                    "respostaApi": _load_json(row.get("respostaApi")) or {},
                    "erro": row.get("erro"),
                    "dadosConference": dados_conference,
                    "criadoEm": _iso(row.get("criadoEm")),
                    "atualizadoEm": _iso(row.get("atualizadoEm")),
                }
            )

        return {
            "ok": True,
            "updatedAt": datetime.now().isoformat(timespec="seconds"),
            "totals": {
                "total": len(rows),
                "valorAprovado": valor_aprovado,
                "erros": sum(1 for item in items if "ERRO" in str(item.get("status") or "")),
                "pendentes": sum(1 for item in items if "PENDENTE" in str(item.get("status") or "")),
            },
            "timeline": sorted(timeline.values(), key=lambda item: item["data"]),
            "byStatus": _entries(by_status),
            "byDecision": _entries(by_decision),
            "items": items,
        }

    def listar_os_login_senhas(
        self,
        limit: int = 1000,
        seguradora: str | None = None,
        empresa: str | None = None,
        incluir_senha: bool = False,
    ) -> dict:
        where = [
            "COALESCE(c.ativoConferencia, 1) = 1",
        ]
        params = []

        seguradora = _to_str(seguradora)
        if seguradora:
            seguradora_like = f"%{seguradora}%"
            where.append(
                """
                (
                    s.codigo = %s
                    OR CAST(s.id AS CHAR) = %s
                    OR LOWER(s.nome) LIKE LOWER(%s)
                    OR LOWER(c.seguradora) LIKE LOWER(%s)
                    OR JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.seguradora_codigo')) = %s
                )
                """
            )
            params.extend([seguradora, seguradora, seguradora_like, seguradora_like, seguradora])

        empresa = _to_str(empresa)
        if empresa:
            empresa_like = f"%{empresa}%"
            where.append(
                """
                (
                    e.codigo = %s
                    OR CAST(e.id AS CHAR) = %s
                    OR LOWER(e.nome) LIKE LOWER(%s)
                    OR JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa')) = %s
                )
                """
            )
            params.extend([empresa, empresa, empresa_like, empresa])

        query = f"""
            SELECT
                c.id AS consolidacaoId,
                c.os,
                c.seguradora,
                c.statusConsolidacao,
                c.acaoSugerida,
                c.gatesValidacao,
                c.dadosConference,
                c.dadosExtraidos,
                c.validacoes,
                c.criadoEm,
                c.atualizadoEm,
                e.id AS empresaId,
                e.codigo AS empresaCodigo,
                e.nome AS empresaNome,
                e.cnpj AS empresaCnpj,
                s.id AS seguradoraId,
                s.codigo AS seguradoraCodigo,
                s.nome AS seguradoraNome,
                s.cnpj AS seguradoraCnpjCadastro,
                p.id AS portalSenhaId,
                p.empresaId AS portalEmpresaId,
                p.seguradoraId AS portalSeguradoraId,
                p.segmento AS portalSegmento,
                p.empresaNome AS portalEmpresaNome,
                p.cnpj AS portalCnpj,
                p.portalNome,
                p.portalUrl,
                p.usuario,
                p.senhaCriptografada,
                p.senhaIv,
                p.senhaTag,
                p.observacao AS portalObservacao
            FROM consolidacoes c
            LEFT JOIN empresas e
              ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
            LEFT JOIN seguradoras s
              ON s.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.seguradora_codigo'))
              OR LOWER(s.nome) = LOWER(c.seguradora)
            LEFT JOIN portais_senhas p
              ON p.empresaId = e.id
              AND p.seguradoraId = s.id
              AND p.ativo = 1
            WHERE {" AND ".join(where)}
            ORDER BY c.atualizadoEm DESC, c.os, p.portalNome, p.usuario
            LIMIT %s
        """
        params.append(int(limit))

        try:
            with self._connect() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute(query, tuple(params))
                    rows = cursor.fetchall()
        except Exception as exc:
            return _dashboard_error(exc, _empty_os_login_senhas())

        items_by_id = {}
        by_seguradora = {}
        by_empresa = {}
        credenciais_total = 0

        for row in rows:
            item = items_by_id.get(row.get("consolidacaoId"))
            if item is None:
                dados_conference = _load_json(row.get("dadosConference")) or {}
                dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}
                validacoes = _load_json(row.get("validacoes")) or {}
                gates_validacao = _load_json(row.get("gatesValidacao")) or _validation_gates(
                    validacoes,
                    dados_conference,
                    dados_extraidos,
                )
                orcamento = _orcamento_resumo(validacoes, dados_extraidos)
                item = {
                    "id": row.get("consolidacaoId"),
                    "os": row.get("os"),
                    "codigoConference": row.get("os"),
                    "osObjeto": _display_os(dados_conference, row.get("os")),
                    "status": _normalizar_status_sem_nbs(row.get("statusConsolidacao") or "NAO_INFORMADO"),
                    "acao": row.get("acaoSugerida"),
                    "empresa": {
                        "id": row.get("empresaId"),
                        "idConference": row.get("empresaId"),
                        "codigo": row.get("empresaCodigo") or dados_conference.get("empresa") or "",
                        "codigoErp": row.get("empresaCodigo") or dados_conference.get("empresa") or "",
                        "nome": row.get("empresaNome") or "",
                        "cnpj": row.get("empresaCnpj") or dados_conference.get("cnpj_empresa") or "",
                    },
                    "seguradora": {
                        "id": row.get("seguradoraId"),
                        "codigo": row.get("seguradoraCodigo") or dados_conference.get("seguradora_codigo") or "",
                        "nome": row.get("seguradoraNome") or row.get("seguradora") or "",
                        "cnpj": row.get("seguradoraCnpjCadastro") or dados_conference.get("cnpj_seguradora") or "",
                    },
                    "dadosOs": _dados_os_resumo(dados_conference),
                    "orcamento": orcamento,
                    "gatesValidacao": gates_validacao,
                    "credenciais": [],
                    "credenciaisStatus": "SEM_CREDENCIAL_EMPRESA_SEGURADORA",
                    "dadosConference": dados_conference,
                    "dadosExtraidos": dados_extraidos,
                    "criadoEm": _iso(row.get("criadoEm")),
                    "atualizadoEm": _iso(row.get("atualizadoEm")),
                }
                items_by_id[row.get("consolidacaoId")] = item
                _increment(by_seguradora, item["seguradora"]["nome"] or "Nao informada")
                _increment(by_empresa, item["empresa"]["nome"] or item["empresa"]["codigo"] or "Nao informada")

            if row.get("portalSenhaId"):
                credential = _portal_credential_payload(row, incluir_senha=incluir_senha)
                if not any(existing.get("id") == credential.get("id") for existing in item["credenciais"]):
                    item["credenciais"].append(credential)
                    item["credenciaisStatus"] = "OK"
                    credenciais_total += 1

        items = list(items_by_id.values())
        return {
            "ok": True,
            "updatedAt": datetime.now().isoformat(timespec="seconds"),
            "filters": {
                "seguradora": seguradora or "",
                "empresa": empresa or "",
                "limit": int(limit),
                "incluirSenha": bool(incluir_senha),
            },
            "totals": {
                "total": len(items),
                "comCredenciais": sum(1 for item in items if item["credenciais"]),
                "semCredenciais": sum(1 for item in items if not item["credenciais"]),
                "credenciais": credenciais_total,
            },
            "bySeguradora": _entries(by_seguradora, reverse=True),
            "byEmpresa": _entries(by_empresa, reverse=True),
            "items": items,
        }

    def importar_portais_senhas_lote(self, payload: Any) -> dict:
        registros = _payload_list(payload)
        if not registros:
            raise ValueError("Informe uma lista de credenciais para importar.")

        normalized = []
        errors = []
        warnings = []
        seen = set()
        for index, registro in enumerate(registros, start=1):
            try:
                item = _normalize_portal_import_item(registro, index)
                key = (
                    item["empresaId"],
                    item["seguradoraId"],
                    item["portalNome"].strip().lower(),
                    item["usuario"].strip().lower(),
                )
                if key in seen:
                    raise ValueError("credencial duplicada no lote para empresaId + seguradoraId + acesso")
                seen.add(key)
                normalized.append(item)
                warnings.extend({"linha": index, "aviso": aviso, "registro": registro} for aviso in item["avisos"])
            except Exception as exc:
                errors.append({"linha": index, "erro": str(exc), "registro": registro})

        if errors:
            raise ValueError(_json({"mensagem": "Lote invalido. Nenhum dado foi apagado.", "erros": errors[:50]}))

        secret = _portal_credentials_secret()
        with self._connect() as conn:
            with conn.cursor(dictionary=True) as cursor:
                self._resolver_empresa_ids_da_carga(cursor, normalized)
                empresa_ids = sorted({item["empresaId"] for item in normalized if item["empresaId"]})
                seguradora_ids = sorted({item["seguradoraId"] for item in normalized})
                empresas_existentes = self._ids_existentes(cursor, "empresas", empresa_ids)
                seguradoras_existentes = self._ids_existentes(cursor, "seguradoras", seguradora_ids)

                missing_empresas = sorted(set(empresa_ids) - empresas_existentes)
                missing_seguradoras = sorted(set(seguradora_ids) - seguradoras_existentes)
                if missing_empresas or missing_seguradoras:
                    raise ValueError(
                        _json(
                            {
                                "mensagem": "IDs de empresa/seguradora inexistentes. Nenhum dado foi apagado.",
                                "empresasNaoEncontradas": missing_empresas,
                                "seguradorasNaoEncontradas": missing_seguradoras,
                            }
                        )
                    )

                try:
                    cursor.execute("DELETE FROM portais_senhas")
                    cursor.execute("ALTER TABLE portais_senhas AUTO_INCREMENT = 1")
                    for item in normalized:
                        encrypted = _encrypt_portal_password(secret, item["senha"])
                        cursor.execute(
                            """
                            INSERT INTO portais_senhas (
                                empresaId,
                                seguradoraId,
                                segmento,
                                empresaNome,
                                cnpj,
                                portalNome,
                                portalUrl,
                                usuario,
                                senhaCriptografada,
                                senhaIv,
                                senhaTag,
                                observacao,
                                ativo
                            )
                            VALUES (
                                %s, %s, %s, %s, %s,
                                %s, %s, %s,
                                %s, %s, %s, %s, 1
                            )
                            """,
                            (
                                item["empresaId"],
                                item["seguradoraId"],
                                item["segmento"],
                                item["empresa"],
                                item["cnpj"],
                                item["portalNome"],
                                item["portalUrl"],
                                item["usuario"],
                                encrypted["encrypted"],
                                encrypted["iv"],
                                encrypted["tag"],
                                item["observacao"],
                            ),
                        )
                    conn.commit()
                except Exception:
                    conn.rollback()
                    raise

        return {
            "ok": True,
            "apagados": True,
            "importados": len(normalized),
            "empresas": len({item["empresaId"] for item in normalized if item["empresaId"]}),
            "seguradoras": len({item["seguradoraId"] for item in normalized}),
            "avisos": warnings,
        }

    def _ids_existentes(self, cursor, table: str, ids: list[int]) -> set[int]:
        if not ids:
            return set()
        placeholders = ", ".join(["%s"] * len(ids))
        cursor.execute(f"SELECT id FROM {table} WHERE id IN ({placeholders})", tuple(ids))
        return {int(row["id"]) for row in cursor.fetchall()}

    def _resolver_empresa_ids_da_carga(self, cursor, items: list[dict]) -> None:
        # O campo idEmpresa da planilha historicamente foi preenchido tanto com
        # empresas.codigo (cod_empresa_erp) quanto com empresas.id. Quando os
        # dois candidatos existem, CNPJ/nome da linha desempata a FK real.
        referencias = sorted({str(item["empresaId"]) for item in items if item.get("empresaId")})
        if not referencias:
            return

        ids_numericos = [int(ref) for ref in referencias if ref.isdigit()]
        id_placeholders = ", ".join(["%s"] * len(ids_numericos)) or "NULL"
        codigo_placeholders = ", ".join(["%s"] * len(referencias))
        cursor.execute(
            f"""
            SELECT id, codigo, nome, cnpj
            FROM empresas
            WHERE codigo IN ({codigo_placeholders})
               OR id IN ({id_placeholders})
            """,
            tuple(referencias + ids_numericos),
        )
        by_codigo: dict[str, list[dict]] = {}
        by_id: dict[str, dict] = {}
        for row in cursor.fetchall():
            row["id"] = int(row["id"])
            by_id[str(row["id"])] = row
            if row.get("codigo") is not None:
                by_codigo.setdefault(str(row["codigo"]), []).append(row)

        for item in items:
            referencia = str(item["empresaId"]) if item.get("empresaId") else ""
            item["empresaReferenciaImportada"] = referencia
            candidatos = []
            candidatos.extend(by_codigo.get(referencia, []))
            if referencia in by_id:
                candidatos.append(by_id[referencia])

            empresa = self._escolher_empresa_da_carga(item, candidatos)
            if empresa:
                item["empresaCodigo"] = str(empresa.get("codigo") or "")
                item["empresaId"] = int(empresa["id"])

    def _escolher_empresa_da_carga(self, item: dict, candidatos: list[dict]) -> dict | None:
        unicos = {int(candidato["id"]): candidato for candidato in candidatos}
        candidatos = list(unicos.values())
        if not candidatos:
            return None
        if len(candidatos) == 1:
            return candidatos[0]

        cnpj_importado = _normalizar_cnpj(item.get("cnpj"))
        if cnpj_importado:
            for candidato in candidatos:
                if _normalizar_cnpj(candidato.get("cnpj")) == cnpj_importado:
                    item["avisos"].append("idEmpresa ambiguo resolvido pelo CNPJ")
                    return candidato

        empresa_importada = _normalizar_nome_empresa(item.get("empresa"))
        if empresa_importada:
            for candidato in candidatos:
                nome_candidato = _normalizar_nome_empresa(candidato.get("nome"))
                if nome_candidato and (nome_candidato == empresa_importada or nome_candidato in empresa_importada or empresa_importada in nome_candidato):
                    item["avisos"].append("idEmpresa ambiguo resolvido pelo nome da empresa")
                    return candidato

        for candidato in candidatos:
            if str(candidato.get("codigo") or "") == str(item.get("empresaId") or ""):
                item["avisos"].append("idEmpresa ambiguo resolvido como cod_empresa_erp")
                return candidato

        item["avisos"].append("idEmpresa ambiguo resolvido como empresas.id")
        return candidatos[0]

    def dashboard_portais_senhas(self) -> dict:
        try:
            with self._connect() as conn:
                with conn.cursor(dictionary=True) as cursor:
                    cursor.execute(
                        """
                        SELECT id, codigo, nome, cnpj
                        FROM seguradoras
                        ORDER BY COALESCE(nome, codigo), codigo
                        """
                    )
                    seguradoras = cursor.fetchall()

                    cursor.execute(
                        """
                        SELECT
                            p.id,
                            p.empresaId,
                            p.segmento,
                            p.empresaNome,
                            p.cnpj,
                            p.portalNome,
                            p.portalUrl,
                            p.usuario,
                            p.senhaCriptografada,
                            p.observacao,
                            p.ativo,
                            DATE_FORMAT(p.criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
                            DATE_FORMAT(p.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm,
                            s.id AS seguradoraId,
                            s.codigo AS seguradoraCodigo,
                            s.nome AS seguradoraNome,
                            e.codigo AS empresaCodigo,
                            e.nome AS empresaNomeCadastro
                        FROM portais_senhas p
                        LEFT JOIN seguradoras s ON s.id = p.seguradoraId
                        LEFT JOIN empresas e ON e.id = p.empresaId
                        ORDER BY p.portalNome, s.nome, p.usuario
                        """
                    )
                    items = cursor.fetchall()
        except Exception as exc:
            return _dashboard_error(exc, {"seguradoras": [], "items": []})

        return {
            "ok": True,
            "updatedAt": datetime.now().isoformat(timespec="seconds"),
            "seguradoras": [_portal_seguradora_payload(row) for row in seguradoras],
            "items": [_portal_senha_dashboard_payload(row) for row in items],
        }

    def _buscar_empresa(self, cursor, codigo=None, cnpj=None):
        cnpj = _normalizar_cnpj(cnpj)
        cursor.execute(
            """
            SELECT id, codigo, nome, cnpj
            FROM empresas
            WHERE (%s IS NOT NULL AND codigo = %s)
               OR (%s IS NOT NULL AND cnpj = %s)
            LIMIT 1
            """,
            (_to_str(codigo), _to_str(codigo), cnpj, cnpj),
        )
        return cursor.fetchone()

    def _buscar_empresa_por_cnpj(self, cursor, cnpj: str):
        cursor.execute(
            """
            SELECT id, codigo, nome, cnpj
            FROM empresas
            WHERE cnpj = %s
            LIMIT 1
            """,
            (cnpj,),
        )
        return cursor.fetchone()

    def _buscar_seguradora(self, cursor, codigo=None, nome=None):
        nome = _to_str(nome)
        cursor.execute(
            """
            SELECT id, codigo, nome, cnpj
            FROM seguradoras
            WHERE (%s IS NOT NULL AND codigo = %s)
               OR (%s IS NOT NULL AND LOWER(nome) = LOWER(%s))
               OR (%s IS NOT NULL AND LOWER(nome) LIKE LOWER(%s))
            LIMIT 1
            """,
            (
                _to_str(codigo),
                _to_str(codigo),
                nome,
                nome,
                nome,
                f"%{nome}%" if nome else None,
            ),
        )
        return cursor.fetchone()

    def _listar_cnpjs_validos(self, cursor, empresa_id: int, seguradora_id: int) -> list[str]:
        cursor.execute(
            """
            SELECT sc.cnpj
            FROM empresa_seguradora_cnpj esc
            JOIN seguradoras_cnpj sc ON sc.id = esc.seguradoraCnpjId
            WHERE esc.empresaId = %s
              AND sc.seguradoraId = %s
              AND esc.ativo = 1
            ORDER BY sc.cnpj
            """,
            (empresa_id, seguradora_id),
        )
        return [row["cnpj"] for row in cursor.fetchall()]


def _empty_os_login_senhas() -> dict:
    return {
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


def _dados_os_resumo(dados_conference: dict) -> dict:
    return {
        "codigo": dados_conference.get("codigo") or dados_conference.get("os") or "",
        "os": dados_conference.get("os") or "",
        "data": dados_conference.get("data") or "",
        "status": dados_conference.get("status") or "",
        "chassi": dados_conference.get("chassi") or "",
        "placa": dados_conference.get("placa") or "",
        "sinistro": dados_conference.get("sinistro") or "",
        "pedidoSeguradora": dados_conference.get("pedido_seguradora") or "",
        "nota": dados_conference.get("nota") or "",
        "serie": dados_conference.get("serie") or "",
        "complemento": bool(dados_conference.get("complemento")),
        "valorPecas": _currency(dados_conference.get("valor_pecas")),
        "valorServicos": _currency(dados_conference.get("valor_servicos")),
        "valorTotal": _currency(dados_conference.get("valor_total")),
        "valorFranquia": _currency(dados_conference.get("valor_franquia")),
    }


def _orcamento_resumo(validacoes: dict, dados_extraidos: dict) -> dict:
    validacao = (validacoes or {}).get("orcamento") or {}
    dados_validacao = validacao.get("dados") or {}
    orcamento = dados_validacao.get("orcamento") or {}
    if not orcamento:
        extraido = (dados_extraidos or {}).get("orcamento") or {}
        orcamentos = extraido.get("orcamento") or []
        orcamento = orcamentos[0] if orcamentos else extraido

    return {
        "status": validacao.get("status") or "",
        "mensagem": validacao.get("mensagem") or "",
        "valorPecas": _currency(orcamento.get("valor_pecas")),
        "valorServicos": _currency(orcamento.get("valor_servicos")),
        "valorTotal": _currency(orcamento.get("valor_total")),
        "valorFranquia": _currency(orcamento.get("valor_franquia")),
        "valorTotalExtraido": _currency(orcamento.get("valor_total_extraido")),
        "valorFranquiaExtraido": _currency(orcamento.get("valor_franquia_extraido")),
        "modeloMo": orcamento.get("modelo_mo") or "",
        "sinistro": orcamento.get("sinistro") or "",
        "dataOrcamento": orcamento.get("data_orcamento") or ((orcamento.get("dados") or {}).get("dataOrcamento")) or "",
        "dadosFaturamento": orcamento.get("dados_faturamento") or orcamento.get("dadosFaturamento") or {},
        "comparacoes": dados_validacao.get("comparacoes") or [],
        "raw": orcamento,
    }


def _portal_credential_payload(row: dict, incluir_senha: bool = False) -> dict:
    payload = {
        "id": row.get("portalSenhaId"),
        "empresaId": int(row["portalEmpresaId"]) if row.get("portalEmpresaId") else None,
        "empresaIdConference": int(row["portalEmpresaId"]) if row.get("portalEmpresaId") else None,
        "empresaCodigoErp": row.get("empresaCodigo") or "",
        "seguradoraId": int(row["portalSeguradoraId"]) if row.get("portalSeguradoraId") else None,
        "segmento": row.get("portalSegmento") or "",
        "empresa": row.get("empresaNome") or row.get("portalEmpresaNome") or "",
        "cnpj": row.get("empresaCnpj") or row.get("portalCnpj") or "",
        "empresaImportada": row.get("portalEmpresaNome") or "",
        "cnpjImportado": row.get("portalCnpj") or "",
        "portalNome": row.get("portalNome") or "",
        "portalUrl": row.get("portalUrl") or "",
        "usuario": row.get("usuario") or "",
        "hasSenha": bool(row.get("senhaCriptografada")),
        "observacao": row.get("portalObservacao") or "",
    }
    if incluir_senha:
        try:
            payload["senha"] = _decrypt_portal_password(
                row.get("senhaCriptografada"),
                row.get("senhaIv"),
                row.get("senhaTag"),
            )
        except Exception as exc:
            payload["senha"] = None
            payload["senhaErro"] = str(exc)
    return payload


def _portal_seguradora_payload(row: dict) -> dict:
    return {
        "id": int(row.get("id")),
        "codigo": row.get("codigo") or "",
        "nome": row.get("nome") or "",
        "cnpj": row.get("cnpj") or "",
    }


def _portal_senha_dashboard_payload(row: dict) -> dict:
    observacao = row.get("observacao") or ""
    return {
        "id": int(row.get("id")),
        "empresaId": int(row["empresaId"]) if row.get("empresaId") else None,
        "empresaCodigo": row.get("empresaCodigo") or "",
        "empresaNomeCadastro": row.get("empresaNomeCadastro") or "",
        "segmento": row.get("segmento") or "",
        "empresaNome": row.get("empresaNome") or "",
        "cnpj": row.get("cnpj") or "",
        "seguradoraId": int(row["seguradoraId"]) if row.get("seguradoraId") else None,
        "seguradoraCodigo": row.get("seguradoraCodigo") or "",
        "seguradoraNome": row.get("seguradoraNome") or "",
        "portalNome": row.get("portalNome") or "",
        "portalUrl": row.get("portalUrl") or "",
        "usuario": row.get("usuario") or "",
        "hasSenha": bool(row.get("senhaCriptografada")),
        "observacao": observacao,
        "importWarnings": _import_warnings(observacao),
        "ativo": bool(row.get("ativo")),
        "criadoEm": row.get("criadoEm"),
        "atualizadoEm": row.get("atualizadoEm"),
    }


def _import_warnings(observacao: str) -> list[str]:
    if not observacao:
        return []
    try:
        payload = json.loads(observacao)
    except (TypeError, ValueError):
        return []
    avisos = payload.get("avisos") if isinstance(payload, dict) else []
    return [str(aviso) for aviso in avisos if aviso] if isinstance(avisos, list) else []


def _payload_list(payload: Any) -> list[dict]:
    if isinstance(payload, list):
        return payload
    if isinstance(payload, dict):
        for key in ("items", "dados", "registros", "credenciais"):
            value = payload.get(key)
            if isinstance(value, list):
                return value
    return []


def _normalize_portal_import_item(registro: Any, index: int) -> dict:
    if not isinstance(registro, dict):
        raise ValueError("registro deve ser um objeto JSON")

    segmento = _required_payload_text(registro, "SEGMENTO", index, 80)
    seguradora = _required_payload_text(registro, "SEGURADORA", index, 180)
    empresa = _required_payload_text(registro, "EMPRESA", index, 180)
    avisos = []
    senha = _first_payload_text(registro, ["SENHA", "senha"], 1000)
    if not senha:
        avisos.append("SENHA vazia")
    empresa_id = _optional_payload_id(registro, "idEmpresa", index, avisos)
    seguradora_id = _required_payload_id(registro, "idSeguradora", index)
    acesso = _first_payload_text(registro, ["ACESSO", "Acesso", "acesso", "URL, ACESSO", "URL_ACESSO", "URL"], 255)
    if not acesso:
        raise ValueError(f"linha {index}: informe ACESSO")

    url = _first_payload_text(registro, ["URL", "url", "PortalUrl", "portalUrl"], 255)
    portal_url = url if _looks_like_url(url) else None
    cnpj = _normalizar_cnpj(_first_payload_text(registro, ["CNPJ", "cnpj"], 32))

    return {
        "segmento": segmento,
        "seguradora": seguradora,
        "empresa": empresa,
        "cnpj": cnpj,
        "portalNome": acesso[:120],
        "portalUrl": portal_url,
        "usuario": acesso[:180],
        "senha": senha,
        "empresaId": empresa_id,
        "seguradoraId": seguradora_id,
        "observacao": _json(
            {
                "origem": "importacao_lote_portais_senhas",
                "linha": index,
                "segmento": segmento,
                "seguradora": seguradora,
                "empresa": empresa,
                "cnpj": cnpj,
                "acesso": acesso,
                "avisos": avisos,
            }
        )[:1000],
        "avisos": avisos,
    }


def _required_payload_text(registro: dict, key: str, index: int, max_length: int) -> str:
    value = _first_payload_text(registro, [key, key.lower()], max_length)
    if not value:
        raise ValueError(f"linha {index}: informe {key}")
    return value


def _required_payload_id(registro: dict, key: str, index: int) -> int:
    value = _first_payload_text(registro, [key, key.lower(), key.upper()], 40)
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        raise ValueError(f"linha {index}: {key} invalido") from None
    if parsed <= 0:
        raise ValueError(f"linha {index}: {key} invalido")
    return parsed


def _optional_payload_id(registro: dict, key: str, index: int, avisos: list[str]) -> int | None:
    value = _first_payload_text(registro, [key, key.lower(), key.upper()], 40)
    try:
        parsed = int(value)
    except (TypeError, ValueError):
        avisos.append(f"{key} invalido: {value or 'vazio'}")
        return None
    if parsed <= 0:
        avisos.append(f"{key} invalido: {value}")
        return None
    return parsed


def _first_payload_text(registro: dict, keys: list[str], max_length: int) -> str:
    normalized = {_normalize_payload_key(key): value for key, value in registro.items()}
    for key in keys:
        value = normalized.get(_normalize_payload_key(key))
        if value not in (None, ""):
            return str(value).strip()[:max_length]
    return ""


def _normalize_payload_key(value: str) -> str:
    return "".join(ch for ch in str(value or "").upper() if ch.isalnum())


def _looks_like_url(value: str | None) -> bool:
    text = (_to_str(value) or "").lower()
    return text.startswith(("http://", "https://", "www.")) or (("." in text) and (" " not in text))


def _portal_credentials_secret() -> str:
    secret = os.getenv("PORTAL_CREDENTIALS_SECRET") or os.getenv("APP_SECRET") or os.getenv("NEXTAUTH_SECRET")
    if not secret or len(secret) < 16:
        raise RuntimeError("Configure PORTAL_CREDENTIALS_SECRET com pelo menos 16 caracteres.")
    return secret


def _encrypt_portal_password(secret: str, password: str) -> dict:
    from cryptography.hazmat.primitives.ciphers.aead import AESGCM

    key = hashlib.sha256(secret.encode("utf-8")).digest()
    iv = os.urandom(12)
    encrypted_with_tag = AESGCM(key).encrypt(iv, password.encode("utf-8"), None)
    encrypted = encrypted_with_tag[:-16]
    tag = encrypted_with_tag[-16:]
    return {
        "encrypted": base64.b64encode(encrypted).decode("ascii"),
        "iv": base64.b64encode(iv).decode("ascii"),
        "tag": base64.b64encode(tag).decode("ascii"),
    }


def _decrypt_portal_password(encrypted: str, iv: str, tag: str) -> str:
    secret = _portal_credentials_secret()

    from cryptography.hazmat.primitives.ciphers.aead import AESGCM

    key = hashlib.sha256(secret.encode("utf-8")).digest()
    payload = base64.b64decode(encrypted or "") + base64.b64decode(tag or "")
    return AESGCM(key).decrypt(base64.b64decode(iv or ""), payload, None).decode("utf-8")


def _json(value) -> str:
    if value is None:
        value = None
    return json.dumps(value, ensure_ascii=False, default=str)


def _load_json(value):
    if value in (None, ""):
        return None
    if isinstance(value, (dict, list)):
        return value
    return json.loads(value)


def _passo2_status_aprovado(status: str) -> bool:
    return status == "APROVADA_CONSOLIDACAO"


def _passo2_status_vermelho(status: str) -> bool:
    if status == "ERRO_TECNICO":
        return False
    return status.startswith("REPROVADA") or status.startswith("FALHA") or status.startswith("ERRO")


def _tem_ajuste_manual(dados_extraidos: dict) -> bool:
    historico = (dados_extraidos or {}).get("ajustes_manuais")
    if isinstance(historico, list) and historico:
        return True

    atuais = (dados_extraidos or {}).get("ajustes_manuais_atuais")
    return isinstance(atuais, dict) and bool(atuais)


def _inserir_fila_fechamento_passo2(
    cursor,
    os_number: str,
    decisao: str,
    status_consolidacao: str,
    ocorrencias: list[dict],
    responsavel: str,
    row: dict,
) -> None:
    cursor.execute(
        """
        INSERT INTO fechamentos (
            os,
            decisao,
            statusFechamento,
            valorAprovado,
            ocorrencias,
            anexos,
            respostaApi,
            erro,
            criadoEm,
            atualizadoEm
        )
        VALUES (%s, %s, 'PENDENTE_PASSO_3', %s, %s, JSON_ARRAY(), %s, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
        """,
        (
            os_number,
            decisao,
            _passo2_valor_aprovado(row) if decisao == "APROVAR" else None,
            _json(ocorrencias or []),
            _json(
                {
                    "pendente": True,
                    "origem": "passo_2_curadoria_automatica",
                    "responsavel": responsavel,
                    "statusConsolidacao": status_consolidacao,
                    "acaoSugeridaAnterior": row.get("acaoSugerida"),
                }
            ),
        ),
    )


def _passo2_ocorrencias_aprovacao(row: dict) -> list[dict]:
    dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}
    ocorrencias = _filtrar_ocorrencias_desativadas(dados_extraidos.get("ocorrencias_passo3") or [])
    if ocorrencias:
        return ocorrencias
    return [{"comentario": "OS validada pela curadoria automatica. Autorizada emissao de nota."}]


def _passo2_valor_aprovado(row: dict):
    validacoes = _load_json(row.get("validacoes")) or {}
    dados_extraidos = _load_json(row.get("dadosExtraidos")) or {}
    dados_conference = _load_json(row.get("dadosConference")) or {}
    orcamento = ((validacoes.get("orcamento") or {}).get("dados") or {}).get("orcamento") or {}
    financeiro = dados_extraidos.get("financeiro_conference") or {}
    return (
        orcamento.get("valor_servicos")
        or dados_conference.get("valor_servicos")
        or financeiro.get("valor_servicos")
        or 0
    )


def _passo2_tokio_cnpj_pendente(row: dict) -> bool:
    if not _normalizar_seguradora(row.get("seguradora") or "").startswith("tokio"):
        return False
    validacoes = _load_json(row.get("validacoes")) or {}
    cnpj = validacoes.get("cnpj") or {}
    return (cnpj.get("status") or STATUS_PENDENTE) == STATUS_PENDENTE


def _passo2_observacao_reprovacao(status: str, dados_extraidos: dict) -> str:
    ocorrencias = _filtrar_ocorrencias_desativadas((dados_extraidos or {}).get("ocorrencias_passo3") or [])
    mensagens = [
        _to_str(item.get("comentario"))
        for item in ocorrencias
        if isinstance(item, dict) and _to_str(item.get("comentario"))
    ]
    if mensagens:
        return " ".join(_dedupe_strings(mensagens))

    fallback = {
        "REPROVADA_FALTA_ANEXO": "Anexos obrigatórios não foram encontrados. OS Reprovada, favor anexar os documentos.",
        "REPROVADA_CNPJ_INVALIDO": "CNPJ divergente ou inválido na validação. OS reprovada automaticamente.",
        "REPROVADA_TERMO_INVALIDO": "Termo de quitação inválido. OS Reprovada, favor corrigir o documento.",
        "REPROVADA_VALOR_DIVERGENTE": "Valores não batem com o Conference.",
    }
    return fallback.get(status, "OS reprovada automaticamente pela validação do RPA. Favor revisar.")


def _dedupe_strings(values: Iterable[str]) -> list[str]:
    seen = set()
    deduped = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        deduped.append(value)
    return deduped


def _filtrar_ocorrencias_desativadas(ocorrencias: list[dict]) -> list[dict]:
    return [item for item in ocorrencias if not isinstance(item, dict) or item.get("id") not in OCORRENCIAS_DESATIVADAS]


def _job_from_row(row: dict | None) -> dict | None:
    if not row:
        return None
    return {
        "id": row.get("id"),
        "tipo": row.get("tipo"),
        "status": row.get("status"),
        "parametros": _load_json(row.get("parametros")) or {},
        "resultado": _load_json(row.get("resultado")) if row.get("resultado") is not None else None,
        "erro": row.get("erro"),
        "iniciadoEm": _iso(row.get("iniciadoEm")),
        "finalizadoEm": _iso(row.get("finalizadoEm")),
        "atualizadoEm": _iso(row.get("atualizadoEm")),
    }


def _resultado_from_dict(payload: dict) -> ResultadoConsolidacao:
    validacoes = {}
    for key, value in (payload.get("validacoes") or {}).items():
        validacoes[key] = ValidacaoResultado(
            item=value.get("item", key),
            status=value.get("status", ""),
            mensagem=value.get("mensagem", ""),
            dados=value.get("dados") or {},
        )

    return ResultadoConsolidacao(
        os=payload.get("os", ""),
        seguradora=payload.get("seguradora", ""),
        status_consolidacao=payload.get("status_consolidacao", ""),
        acao_sugerida=payload.get("acao_sugerida", ""),
        validacoes=validacoes,
        dados_conference=payload.get("dados_conference") or {},
        dados_extraidos=payload.get("dados_extraidos") or {},
        erros=payload.get("erros") or [],
        criado_em=payload.get("criado_em") or datetime.now().isoformat(timespec="seconds"),
    )


def _normalizar_contexto_fechamento(consolidacao: dict, decisao: dict | None = None) -> dict:
    decisao = decisao or {}
    return {
        "os": consolidacao.get("os"),
        "seguradora": consolidacao.get("seguradora"),
        "statusConsolidacao": consolidacao.get("statusConsolidacao"),
        "acaoSugerida": consolidacao.get("acaoSugerida"),
        "curadorAprovado": bool(consolidacao.get("curadorAprovado")),
        "dadosConference": _load_json(consolidacao.get("dadosConference")) or {},
        "dadosExtraidos": _load_json(consolidacao.get("dadosExtraidos")) or {},
        "validacoes": _load_json(consolidacao.get("validacoes")) or {},
        "resultadoJson": _load_json(consolidacao.get("resultadoJson")) or {},
        "decisaoHumana": {
            "decisao": decisao.get("decisao"),
            "observacao": decisao.get("observacao"),
            "responsavel": decisao.get("responsavel"),
            "dadosDecisao": _load_json(decisao.get("dadosDecisao")) or {},
            "criadoEm": _iso(decisao.get("criadoEm")),
        }
        if decisao.get("decisao")
        else None,
        "fechamentoId": (decisao.get("dadosDecisao") or {}).get("fechamentoId")
        if isinstance(decisao.get("dadosDecisao"), dict)
        else None,
    }


def _to_str(value):
    if value in (None, ""):
        return None
    return str(value)


def _first_value(registro: dict, keys: list[str]):
    for key in keys:
        value = registro.get(key)
        if value not in (None, ""):
            return value
    return None


def _only_digits(value):
    if value in (None, ""):
        return None
    return "".join(ch for ch in str(value) if ch.isdigit()) or None


def _normalizar_cnpj(value):
    digits = _only_digits(value)
    if not digits:
        return None
    if len(digits) < 14:
        digits = digits.zfill(14)
    return digits


def _normalizar_nome_empresa(value):
    if value in (None, ""):
        return ""
    return " ".join(str(value).strip().lower().split())


def _format_cnpj(value) -> str:
    digits = _normalizar_cnpj(value)
    if not digits or len(digits) != 14:
        return str(value or "")
    return f"{digits[:2]}.{digits[2:5]}.{digits[5:8]}/{digits[8:12]}-{digits[12:]}"


def _normalizar_seguradora(value: str) -> str:
    normalized = (
        str(value or "")
        .strip()
        .lower()
        .replace("á", "a")
        .replace("à", "a")
        .replace("ã", "a")
        .replace("â", "a")
        .replace("é", "e")
        .replace("ê", "e")
        .replace("í", "i")
        .replace("ó", "o")
        .replace("ô", "o")
        .replace("õ", "o")
        .replace("ú", "u")
        .replace("ç", "c")
    )
    return "_".join(normalized.split())


def _validacoes_to_model(validacoes: dict) -> dict[str, ValidacaoResultado]:
    converted = {}
    for key, value in (validacoes or {}).items():
        value = value or {}
        converted[key] = ValidacaoResultado(
            item=value.get("item") or key,
            status=value.get("status") or STATUS_PENDENTE,
            mensagem=value.get("mensagem") or "",
            dados=value.get("dados") or {},
        )
    return converted


def _ocorrencias_cnpj_manual(cnpj: str, aprovado: bool) -> list[dict]:
    cnpj_formatado = _format_cnpj(cnpj)
    if aprovado:
        return [
            {
                "id": "C14",
                "comentario": f"CNPJ {cnpj_formatado} aprovado manualmente pela curadoria.",
                "origem": "cnpj",
            }
        ]
    return [
        {
            "id": "C26",
            "comentario": f"CNPJ {cnpj_formatado} reprovado manualmente pela curadoria.",
            "origem": "cnpj",
        }
    ]


def _dedupe_ocorrencias_dict(ocorrencias: list[dict]) -> list[dict]:
    seen = set()
    deduped = []
    for ocorrencia in ocorrencias or []:
        if not isinstance(ocorrencia, dict):
            continue
        key = (ocorrencia.get("id"), ocorrencia.get("comentario"))
        if key in seen:
            continue
        seen.add(key)
        deduped.append(ocorrencia)
    return deduped


def _eh_bradesco(dados: dict, seguradora: str | None = None) -> bool:
    nome = _to_str(dados.get("seguradora") or seguradora) or ""
    return nome.strip().lower() == "bradesco" or str(dados.get("seguradora_codigo") or "") == "4"


def _conference_snapshot_from_registro(registro: dict, codigo: str) -> dict:
    valor_pecas = _currency_or_none(_first_value(registro, ["valor_pecas", "tot_pecas"]))
    valor_servicos = _currency_or_none(_first_value(registro, ["valor_servicos", "tot_servicos"]))
    valor_total = _currency_or_none(_first_value(registro, ["valor", "valor_total", "total", "saldo"]))
    if valor_total is None and valor_pecas is not None and valor_servicos is not None:
        valor_total = _currency(valor_pecas + valor_servicos)

    return {
        "os": _to_str(_first_value(registro, ["os", "ordem_servico", "numero_os"])) or codigo,
        "seguradora": _to_str(_first_value(registro, ["seguradora", "cia", "cia_seguradora"])) or "",
        "codigo": _to_str(_first_value(registro, ["codigo"])),
        "empresa": _to_str(_first_value(registro, ["empresa"])),
        "empresa_erp": _to_str(_first_value(registro, ["empresa_erp"])),
        "seguradora_codigo": _to_str(_first_value(registro, ["seguradora_codigo"])),
        "cnpj_empresa": _first_value(registro, ["cnpj_empresa", "cnpj_oficina"]),
        "cnpj_seguradora": _first_value(registro, ["cnpj_seguradora", "cnpj_cia", "seguradora_cnpj"]),
        "intermediadora_codigo": _to_str(_first_value(registro, ["intermediadora_codigo"])),
        "intermediadora": _to_str(_first_value(registro, ["intermediadora"])),
        "nota": _to_str(_first_value(registro, ["nota"])),
        "data": _to_str(_first_value(registro, ["data"])),
        "serie": _to_str(_first_value(registro, ["serie"])),
        "chassi": _to_str(_first_value(registro, ["chassi"])),
        "placa": _to_str(_first_value(registro, ["placa"])),
        "sinistro": _to_str(_first_value(registro, ["sinistro"])),
        "pedido_seguradora": _to_str(_first_value(registro, ["pedido_seguradora"])),
        "status": _to_str(_first_value(registro, ["status"])),
        "valor_servicos": valor_servicos,
        "valor_pecas": valor_pecas,
        "valor_total": valor_total,
        "valor_franquia": _currency_or_none(_first_value(registro, ["valor_franquia", "franquia"])),
        "complemento": _first_value(
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
        "checklist": {},
        "anexos": [],
        "raw": registro,
    }


def _display_os(dados_conference: dict, fallback: str | None = None):
    return (
        dados_conference.get("osObjeto")
        or dados_conference.get("os_objeto")
        or dados_conference.get("os_atri")
        or (dados_conference.get("raw") or {}).get("os")
        or (dados_conference.get("raw") or {}).get("ordem_servico")
        or (dados_conference.get("raw") or {}).get("numero_os")
        or dados_conference.get("os")
        or fallback
    )


def _validation_gates(validacoes: dict, dados_conference: dict, dados_extraidos: dict) -> dict:
    orcamento = validacoes.get("orcamento") or {}
    anexos = validacoes.get("anexos") or {}
    return {
        "cnpj": _gate_from_validation("cnpj", "CNPJ", validacoes.get("cnpj")),
        "orcamento": _gate_from_validation("orcamento", "Orçamento", orcamento),
        "valor_franquia": _gate_from_comparison(
            "valor_franquia",
            "Valor da franquia",
            orcamento,
            "valor_franquia",
            dados_conference,
            dados_extraidos,
        ),
        "termo_quitacao": _gate_from_validation(
            "termo_quitacao",
            "Termo de Quitação",
            validacoes.get("termo_quitacao"),
        ),
        "fotos_anexos": _gate_from_anexo("fotos_anexos", "Fotos nos anexos", anexos, "fotos"),
        "conhecimento_transporte": _gate_from_anexo(
            "conhecimento_transporte",
            "Conhecimento de transporte",
            anexos,
            "conhecimento_transporte",
        ),
        "nf_fabrica": _gate_from_anexo("nf_fabrica", "NF de Fábrica", anexos, "nf_fabrica"),
    }


def _gate_from_validation(key: str, label: str, validation: dict | None) -> dict:
    if not validation:
        return {
            "key": key,
            "label": label,
            "status": STATUS_PENDENTE,
            "mensagem": "Gate ainda nao foi validado nesta execucao.",
            "dados": {},
        }
    return {
        "key": key,
        "label": label,
        "status": validation.get("status") or STATUS_PENDENTE,
        "mensagem": validation.get("mensagem") or "",
        "dados": validation.get("dados") or {},
    }


def _gate_from_comparison(
    key: str,
    label: str,
    orcamento_validation: dict,
    campo: str,
    dados_conference: dict,
    dados_extraidos: dict,
) -> dict:
    comparacao = _comparison_by_field(orcamento_validation, campo)
    if not comparacao:
        return {
            "key": key,
            "label": label,
            "status": STATUS_PENDENTE,
            "mensagem": "Comparacao de valores ainda nao disponivel.",
            "dados": {
                "conference": _financial_value(dados_conference, dados_extraidos, campo),
                "orcamento": None,
                "diferenca": None,
            },
        }

    status = STATUS_APROVADO if comparacao.get("confere") else STATUS_REPROVADO
    return {
        "key": key,
        "label": label,
        "status": status,
        "mensagem": "Valor confere no batimento." if status == STATUS_APROVADO else "Valor diverge no batimento.",
        "dados": {
            "conference": comparacao.get("conference"),
            "orcamento": comparacao.get("orcamento"),
            "diferenca": comparacao.get("diferenca"),
        },
    }


def _gate_from_anexo(key: str, label: str, anexos_validation: dict, tipo: str) -> dict:
    dados = anexos_validation.get("dados") or {}
    faltantes = dados.get("faltantes") or []
    arquivos = dados.get("arquivos") or {}

    if tipo in arquivos and arquivos.get(tipo):
        return {
            "key": key,
            "label": label,
            "status": STATUS_APROVADO,
            "mensagem": "Anexo encontrado.",
            "dados": {"arquivo": arquivos.get(tipo)},
        }

    if tipo in faltantes:
        return {
            "key": key,
            "label": label,
            "status": STATUS_REPROVADO,
            "mensagem": "Anexo obrigatorio nao encontrado.",
            "dados": {"tipo": tipo},
        }

    return {
        "key": key,
        "label": label,
        "status": STATUS_PENDENTE,
        "mensagem": "Regra de anexo aguardando evidencias nesta execucao.",
        "dados": {"tipo": tipo},
    }


def _comparison_by_field(orcamento_validation: dict, campo: str) -> dict | None:
    comparacoes = ((orcamento_validation or {}).get("dados") or {}).get("comparacoes") or []
    for comparacao in comparacoes:
        if comparacao.get("campo") == campo:
            return comparacao
    return None


def _financial_value(dados_conference: dict, dados_extraidos: dict, campo: str):
    financeiro = (dados_extraidos or {}).get("financeiro_conference") or {}
    return (dados_conference or {}).get(campo) or financeiro.get(campo)


def _int_or_zero(value) -> int:
    try:
        return int(value or 0)
    except (TypeError, ValueError):
        return 0


def _normalizar_status_sem_nbs(status: str | None) -> str:
    if status == "FALHA_SINCRONIZACAO_NBS_FECHAR_MANUAL":
        return "REPROVADA_VALOR_DIVERGENTE"
    return status or "NAO_INFORMADO"


def _is_complementar(validacoes: dict) -> bool:
    complemento = (((validacoes or {}).get("orcamento") or {}).get("dados") or {}).get("complemento") or {}
    return bool(complemento.get("manual"))


def _balance_difference(validacoes: dict, gates_validacao: dict) -> float | None:
    gate_difference = (((gates_validacao or {}).get("orcamento") or {}).get("dados") or {}).get("diferenca")
    if gate_difference is not None:
        return _currency_or_none(gate_difference)

    comparacao = _comparison_by_field((validacoes or {}).get("orcamento") or {}, "valor_total")
    if not comparacao or comparacao.get("diferenca") is None:
        return None
    return _currency_or_none(comparacao.get("diferenca"))


def _balance_search_text(value: float | None) -> str:
    if value is None:
        return "batimento pendente"
    if abs(float(value)) <= 0.01:
        return "batimento aprovado zero ok"
    return f"batimento reprovado divergente {float(value):.2f}"


def _conference_value(row: dict) -> float:
    dados_conference = _load_json(row.get("dadosConference")) or {}
    resultado_json = _load_json(row.get("resultadoJson")) or {}
    resultado_conference = resultado_json.get("dados_conference") or {}
    financeiro = (resultado_json.get("dados_extraidos") or {}).get("financeiro_conference") or {}
    return _currency(
        dados_conference.get("valor_total")
        or resultado_conference.get("valor_total")
        or financeiro.get("valor_total")
        or 0
    )


def _conference_status(dados_conference: dict) -> str:
    raw = (dados_conference or {}).get("raw") or {}
    return str(
        (dados_conference or {}).get("status")
        or raw.get("status")
        or raw.get("status_codigo")
        or raw.get("statusCode")
        or ""
    ).strip()


def _encerrado_manualmente(dados_conference: dict) -> bool:
    status = _conference_status(dados_conference)
    return bool(status) and status != "5"


def _registro_dentro_periodo(dados_conference: dict, data_inicial: str | None, data_final: str | None) -> bool:
    if not data_inicial and not data_final:
        return True

    raw = (dados_conference or {}).get("raw") or {}
    data_registro = _parse_date(
        (dados_conference or {}).get("data")
        or raw.get("data")
        or raw.get("data_abertura")
        or raw.get("data_cadastro")
        or raw.get("data_atualizacao")
    )
    if not data_registro:
        return False

    inicio = _parse_date(data_inicial) if data_inicial else None
    fim = _parse_date(data_final) if data_final else None
    if inicio and data_registro < inicio:
        return False
    if fim and data_registro > fim:
        return False
    return True


def _parse_date(value):
    if not value:
        return None
    if hasattr(value, "date"):
        return value.date()

    text = str(value).strip()
    for fmt in ("%d/%m/%Y %H:%M:%S", "%d/%m/%Y", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d"):
        try:
            return datetime.strptime(text[:19] if "%H" in fmt else text[:10], fmt).date()
        except ValueError:
            continue
    return None


def _currency(value) -> float:
    if value in (None, ""):
        return 0.0
    try:
        return round(float(value), 2)
    except (TypeError, ValueError):
        return 0.0


def _currency_or_none(value):
    if value in (None, ""):
        return None
    try:
        normalized = str(value).strip()
        if "," in normalized:
            normalized = normalized.replace(".", "").replace(",", ".")
        return round(float(normalized), 2)
    except (TypeError, ValueError):
        return None


def _date_key(value) -> str:
    if not value:
        return "sem-data"
    if hasattr(value, "date"):
        return value.date().isoformat()
    return str(value)[:10]


def _iso(value):
    if not value:
        return None
    if hasattr(value, "isoformat"):
        return value.isoformat()
    return str(value)


def _increment(mapping: dict, key: str, amount: int = 1) -> None:
    mapping[key] = mapping.get(key, 0) + amount


def _entries(mapping: dict, reverse: bool = False) -> list[dict]:
    items = [{"key": key, "value": value} for key, value in mapping.items()]
    if reverse:
        return sorted(items, key=lambda item: item["value"], reverse=True)
    return sorted(items, key=lambda item: str(item["key"]))


def _dashboard_error(exc: Exception, fallback: dict) -> dict:
    fallback = dict(fallback)
    fallback["ok"] = False
    fallback["error"] = _safe_dashboard_error(exc)
    return fallback


def _safe_dashboard_error(exc: Exception) -> str:
    message = str(exc).replace("\n", " ")
    if "Access denied" in message or "Authentication failed" in message:
        return "Falha de autenticacao ao consultar o banco de dados."
    if "doesn't exist" in message and "fechamentos" in message:
        return "Tabela fechamentos ainda nao existe."
    return message[:300]


def _empty_consolidacoes() -> dict:
    return {
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


def _empty_fechamentos() -> dict:
    return {
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


def _empty_execucoes() -> dict:
    return {
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
