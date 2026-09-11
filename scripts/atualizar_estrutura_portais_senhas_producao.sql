SET NAMES utf8mb4;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS add_portais_senhas_column;
DELIMITER //
CREATE PROCEDURE add_portais_senhas_column(
  IN column_name VARCHAR(64),
  IN column_definition TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'portais_senhas'
      AND COLUMN_NAME = column_name
  ) THEN
    SET @ddl = CONCAT('ALTER TABLE portais_senhas ADD COLUMN ', column_name, ' ', column_definition);
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END//
DELIMITER ;

CALL add_portais_senhas_column('empresaId', 'INT NULL');
CALL add_portais_senhas_column('seguradoraId', 'INT NULL');
CALL add_portais_senhas_column('segmento', 'VARCHAR(80) NULL');
CALL add_portais_senhas_column('empresaNome', 'VARCHAR(180) NULL');
CALL add_portais_senhas_column('cnpj', 'VARCHAR(14) NULL');
CALL add_portais_senhas_column('portalUrl', 'VARCHAR(255) NULL');
CALL add_portais_senhas_column('observacao', 'TEXT NULL');
CALL add_portais_senhas_column('ativo', 'TINYINT(1) NOT NULL DEFAULT 1');
CALL add_portais_senhas_column('criadoEm', 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP');
CALL add_portais_senhas_column('atualizadoEm', 'DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');

DROP PROCEDURE add_portais_senhas_column;

DROP PROCEDURE IF EXISTS add_portais_senhas_index;
DELIMITER //
CREATE PROCEDURE add_portais_senhas_index(
  IN index_name VARCHAR(64),
  IN index_columns TEXT
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'portais_senhas'
      AND INDEX_NAME = index_name
  ) THEN
    SET @ddl = CONCAT('ALTER TABLE portais_senhas ADD INDEX ', index_name, ' (', index_columns, ')');
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END//
DELIMITER ;

CALL add_portais_senhas_index('portais_senhas_empresaId_idx', 'empresaId');
CALL add_portais_senhas_index('portais_senhas_seguradoraId_idx', 'seguradoraId');
CALL add_portais_senhas_index('portais_senhas_portalNome_idx', 'portalNome');
CALL add_portais_senhas_index('portais_senhas_empresa_seguradora_idx', 'empresaId, seguradoraId');

DROP PROCEDURE add_portais_senhas_index;

DROP PROCEDURE IF EXISTS add_portais_senhas_fk;
DELIMITER //
CREATE PROCEDURE add_portais_senhas_fk(
  IN constraint_name VARCHAR(64),
  IN column_name VARCHAR(64),
  IN referenced_table VARCHAR(64)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'portais_senhas'
      AND CONSTRAINT_NAME = constraint_name
  ) THEN
    SET @ddl = CONCAT(
      'ALTER TABLE portais_senhas ADD CONSTRAINT ',
      constraint_name,
      ' FOREIGN KEY (',
      column_name,
      ') REFERENCES ',
      referenced_table,
      '(id) ON DELETE SET NULL ON UPDATE CASCADE'
    );
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END//
DELIMITER ;

CALL add_portais_senhas_fk('portais_senhas_empresaId_fkey', 'empresaId', 'empresas');
CALL add_portais_senhas_fk('portais_senhas_seguradoraId_fkey', 'seguradoraId', 'seguradoras');

DROP PROCEDURE add_portais_senhas_fk;

DROP TABLE IF EXISTS empresa_portal_senhas;
