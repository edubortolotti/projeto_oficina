#!/usr/bin/env node
const { PrismaClient } = require("@prisma/client");

const prisma = new PrismaClient();

async function main() {
  await prisma.$executeRawUnsafe(`
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
  `);

  await ensureColumn("empresaId", "INT NULL");
  await ensureColumn("seguradoraId", "INT NULL");
  await ensureColumn("segmento", "VARCHAR(80) NULL");
  await ensureColumn("empresaNome", "VARCHAR(180) NULL");
  await ensureColumn("cnpj", "VARCHAR(14) NULL");
  await ensureColumn("portalUrl", "VARCHAR(255) NULL");
  await ensureColumn("observacao", "TEXT NULL");
  await ensureColumn("ativo", "TINYINT(1) NOT NULL DEFAULT 1");
  await ensureColumn("criadoEm", "DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP");
  await ensureColumn("atualizadoEm", "DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");

  await ensureIndex("portais_senhas_empresaId_idx", "empresaId");
  await ensureIndex("portais_senhas_seguradoraId_idx", "seguradoraId");
  await ensureIndex("portais_senhas_portalNome_idx", "portalNome");
  await ensureIndex("portais_senhas_empresa_seguradora_idx", "empresaId, seguradoraId");

  await ensureForeignKey("portais_senhas_empresaId_fkey", "empresaId", "empresas");
  await ensureForeignKey("portais_senhas_seguradoraId_fkey", "seguradoraId", "seguradoras");

  await prisma.$executeRawUnsafe("DROP TABLE IF EXISTS empresa_portal_senhas");
  console.log("Estrutura de portais_senhas atualizada.");
}

async function ensureColumn(columnName, definition) {
  const rows = await prisma.$queryRawUnsafe(
    `
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'portais_senhas'
        AND COLUMN_NAME = ?
      LIMIT 1
    `,
    columnName,
  );
  if (!rows.length) {
    await prisma.$executeRawUnsafe(`ALTER TABLE portais_senhas ADD COLUMN ${columnName} ${definition}`);
  }
}

async function ensureIndex(indexName, columns) {
  const rows = await prisma.$queryRawUnsafe(
    `
      SELECT 1
      FROM information_schema.STATISTICS
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'portais_senhas'
        AND INDEX_NAME = ?
      LIMIT 1
    `,
    indexName,
  );
  if (!rows.length) {
    await prisma.$executeRawUnsafe(`ALTER TABLE portais_senhas ADD INDEX ${indexName} (${columns})`);
  }
}

async function ensureForeignKey(constraintName, columnName, referencedTable) {
  const rows = await prisma.$queryRawUnsafe(
    `
      SELECT 1
      FROM information_schema.KEY_COLUMN_USAGE
      WHERE TABLE_SCHEMA = DATABASE()
        AND TABLE_NAME = 'portais_senhas'
        AND CONSTRAINT_NAME = ?
      LIMIT 1
    `,
    constraintName,
  );
  if (!rows.length) {
    await prisma.$executeRawUnsafe(`
      ALTER TABLE portais_senhas
      ADD CONSTRAINT ${constraintName}
      FOREIGN KEY (${columnName}) REFERENCES ${referencedTable}(id)
      ON DELETE SET NULL ON UPDATE CASCADE
    `);
  }
}

main()
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
