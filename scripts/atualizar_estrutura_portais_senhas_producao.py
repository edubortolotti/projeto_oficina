#!/usr/bin/env python3
import os
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

import mysql.connector

PROJECT_ROOT = Path(__file__).resolve().parents[1]
if os.fspath(PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, os.fspath(PROJECT_ROOT))

from core.env import load_dotenv


def connect():
    load_dotenv()
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError("Configure DATABASE_URL para atualizar a estrutura em producao.")

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


def exists(cursor, query, params):
    cursor.execute(query, params)
    return cursor.fetchone() is not None


def ensure_column(cursor, column_name, definition):
    if exists(
        cursor,
        """
        SELECT 1
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'portais_senhas'
          AND COLUMN_NAME = %s
        LIMIT 1
        """,
        (column_name,),
    ):
        return

    cursor.execute(f"ALTER TABLE portais_senhas ADD COLUMN {column_name} {definition}")


def ensure_index(cursor, index_name, columns):
    if exists(
        cursor,
        """
        SELECT 1
        FROM information_schema.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'portais_senhas'
          AND INDEX_NAME = %s
        LIMIT 1
        """,
        (index_name,),
    ):
        return

    cursor.execute(f"ALTER TABLE portais_senhas ADD INDEX {index_name} ({columns})")


def ensure_foreign_key(cursor, constraint_name, column_name, referenced_table):
    if exists(
        cursor,
        """
        SELECT 1
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = 'portais_senhas'
          AND CONSTRAINT_NAME = %s
        LIMIT 1
        """,
        (constraint_name,),
    ):
        return

    cursor.execute(
        f"""
        ALTER TABLE portais_senhas
        ADD CONSTRAINT {constraint_name}
        FOREIGN KEY ({column_name}) REFERENCES {referenced_table}(id)
        ON DELETE SET NULL ON UPDATE CASCADE
        """
    )


def main():
    with connect() as conn:
        with conn.cursor() as cursor:
            cursor.execute("SET NAMES utf8mb4")
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
                  PRIMARY KEY (id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
                """
            )

            ensure_column(cursor, "empresaId", "INT NULL")
            ensure_column(cursor, "seguradoraId", "INT NULL")
            ensure_column(cursor, "segmento", "VARCHAR(80) NULL")
            ensure_column(cursor, "empresaNome", "VARCHAR(180) NULL")
            ensure_column(cursor, "cnpj", "VARCHAR(14) NULL")
            ensure_column(cursor, "portalUrl", "VARCHAR(255) NULL")
            ensure_column(cursor, "observacao", "TEXT NULL")
            ensure_column(cursor, "ativo", "TINYINT(1) NOT NULL DEFAULT 1")
            ensure_column(cursor, "criadoEm", "DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP")
            ensure_column(cursor, "atualizadoEm", "DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP")

            ensure_index(cursor, "portais_senhas_empresaId_idx", "empresaId")
            ensure_index(cursor, "portais_senhas_seguradoraId_idx", "seguradoraId")
            ensure_index(cursor, "portais_senhas_portalNome_idx", "portalNome")
            ensure_index(cursor, "portais_senhas_empresa_seguradora_idx", "empresaId, seguradoraId")

            ensure_foreign_key(cursor, "portais_senhas_empresaId_fkey", "empresaId", "empresas")
            ensure_foreign_key(cursor, "portais_senhas_seguradoraId_fkey", "seguradoraId", "seguradoras")

            cursor.execute("DROP TABLE IF EXISTS empresa_portal_senhas")
            conn.commit()

    print("Estrutura de portais_senhas atualizada.")


if __name__ == "__main__":
    main()
