-- Importacao de senhas de portais gerada automaticamente.
-- Gerado em: 2026-06-30 12:48:36
-- Origem: /Users/edubort/Downloads/Planilha de Senhas (Oficinas) - atualizado em 25.06.xlsx
-- Linhas validas para carga: 246
-- Linhas ignoradas por campos obrigatorios ausentes: 24
SET NAMES utf8mb4;
USE `rpa_oficinas`;
START TRANSACTION;

-- Linhas ignoradas:
-- linha 8: ausente SENHA
-- linha 13: ausente USUÁRIO2
-- linha 20: ausente USUÁRIO2
-- linha 35: ausente USUÁRIO2
-- linha 56: ausente USUÁRIO2
-- linha 69: ausente USUÁRIO2
-- linha 71: ausente USUÁRIO2
-- linha 142: ausente USUÁRIO2
-- linha 188: ausente USUÁRIO2
-- linha 191: ausente SENHA
-- linha 192: ausente SENHA
-- linha 195: ausente USUÁRIO2
-- linha 196: ausente USUÁRIO2
-- linha 207: ausente SENHA
-- linha 211: ausente USUÁRIO2
-- linha 212: ausente SENHA
-- linha 216: ausente USUÁRIO2
-- linha 220: ausente USUÁRIO2
-- linha 224: ausente USUÁRIO2
-- linha 230: ausente USUÁRIO2
-- linha 231: ausente SENHA
-- linha 234: ausente SENHA
-- linha 238: ausente USUÁRIO2
-- linha 267: ausente USUÁRIO2

-- Linha 2
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '2359406'
    AND usuario = 'heliton'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '0TgmZdI=',
  senhaIv = 'DW/eqquXjCNZZrEm',
  senhaTag = 'oRanOS5oSCxHPuw7FGcdlA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 2 | Segmento: ALL RISK | Seguradora: ALLIANZ (AR) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 2359406',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '2359406', NULL, 'heliton',
  '0TgmZdI=', 'DW/eqquXjCNZZrEm', 'oRanOS5oSCxHPuw7FGcdlA==', 'Origem: planilha de senhas de oficinas, linha 2 | Segmento: ALL RISK | Seguradora: ALLIANZ (AR) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 2359406', 1
WHERE @portalCredentialId IS NULL;

-- Linha 3
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '2359406'
    AND usuario = 'EDSON'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '7b3ikxU=',
  senhaIv = 'Kc27HbpjdSkGl0ah',
  senhaTag = 'iLPT594eIldVX565adk4CQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 3 | Segmento: ALL RISK | Seguradora: ALLIANZ (AR) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 2359406',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '2359406', NULL, 'EDSON',
  '7b3ikxU=', 'Kc27HbpjdSkGl0ah', 'iLPT594eIldVX565adk4CQ==', 'Origem: planilha de senhas de oficinas, linha 3 | Segmento: ALL RISK | Seguradora: ALLIANZ (AR) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 2359406', 1
WHERE @portalCredentialId IS NULL;

-- Linha 4
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP123903'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'tniQE16/wepf+Q==',
  senhaIv = 'dIFVIfOQpblALtTH',
  senhaTag = 'epGYbQwRgxlY20MURv5q/g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 4 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: BP123903',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP123903', NULL, '-----',
  'tniQE16/wepf+Q==', 'dIFVIfOQpblALtTH', 'epGYbQwRgxlY20MURv5q/g==', 'Origem: planilha de senhas de oficinas, linha 4 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: BP123903', 1
WHERE @portalCredentialId IS NULL;

-- Linha 5
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP104509'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'wOBOXv2MEnqbbw==',
  senhaIv = 'Wze86OPn71vwF/2v',
  senhaTag = 'EytJzo3DsDWmFD5J0JOhyQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 5 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: BP104509',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP104509', NULL, '-----',
  'wOBOXv2MEnqbbw==', 'Wze86OPn71vwF/2v', 'EytJzo3DsDWmFD5J0JOhyQ==', 'Origem: planilha de senhas de oficinas, linha 5 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: BP104509', 1
WHERE @portalCredentialId IS NULL;

-- Linha 6
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP101585'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'uBT23Z6J5y4rmQ==',
  senhaIv = 'ctRq/fIm5BzS0iOR',
  senhaTag = 'V3Zm/U11sJrTLweZjVZwIg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 6 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: BP101585',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP101585', NULL, '-----',
  'uBT23Z6J5y4rmQ==', 'ctRq/fIm5BzS0iOR', 'V3Zm/U11sJrTLweZjVZwIg==', 'Origem: planilha de senhas de oficinas, linha 6 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: BP101585', 1
WHERE @portalCredentialId IS NULL;

-- Linha 7
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP101779'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'pCkVsQnihHHrMs4HrBM1NQ==',
  senhaIv = 'Y7+PR+r+/RlHjMlP',
  senhaTag = 'dtkS2bW9iaXVngDhLI+aHg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 7 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: BP101779',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP101779', NULL, '-----',
  'pCkVsQnihHHrMs4HrBM1NQ==', 'Y7+PR+r+/RlHjMlP', 'dtkS2bW9iaXVngDhLI+aHg==', 'Origem: planilha de senhas de oficinas, linha 7 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: BP101779', 1
WHERE @portalCredentialId IS NULL;

-- Linha 9
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP105850'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'DYWtNOe0XEbKcTK0xA0=',
  senhaIv = 'Hyqb1RYJFfFuWo9l',
  senhaTag = '0F0RUrHLTKWuajQUqjgHxg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 9 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: BP105850',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP105850', NULL, '-----',
  'DYWtNOe0XEbKcTK0xA0=', 'Hyqb1RYJFfFuWo9l', '0F0RUrHLTKWuajQUqjgHxg==', 'Origem: planilha de senhas de oficinas, linha 9 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: BP105850', 1
WHERE @portalCredentialId IS NULL;

-- Linha 10
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP113731'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Qoixr89RvUMDU/5d',
  senhaIv = 'v5AYd3VuFR2UFbcn',
  senhaTag = 'd7kwAAyiJWFSOO9SENKSyw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 10 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: BP113731',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP113731', NULL, '-----',
  'Qoixr89RvUMDU/5d', 'v5AYd3VuFR2UFbcn', 'd7kwAAyiJWFSOO9SENKSyw==', 'Origem: planilha de senhas de oficinas, linha 10 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: BP113731', 1
WHERE @portalCredentialId IS NULL;

-- Linha 11
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP129154'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Swjh8kf9xn4Lj0sa6M8=',
  senhaIv = 'pvXxprSBvkQHF6zR',
  senhaTag = 'b4Q1ozVQrMnHQslw4CvZQA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 11 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: BP129154',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP129154', NULL, '-----',
  'Swjh8kf9xn4Lj0sa6M8=', 'pvXxprSBvkQHF6zR', 'b4Q1ozVQrMnHQslw4CvZQA==', 'Origem: planilha de senhas de oficinas, linha 11 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: BP129154', 1
WHERE @portalCredentialId IS NULL;

-- Linha 12
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP101636'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'flGbytt4HtIHTv2HtUpx',
  senhaIv = 'e0kycWqtqKeoCPz2',
  senhaTag = 'dA2KPmPxVhT44Qns3t9DjA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 12 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: BP101636',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP101636', NULL, '-----',
  'flGbytt4HtIHTv2HtUpx', 'e0kycWqtqKeoCPz2', 'dA2KPmPxVhT44Qns3t9DjA==', 'Origem: planilha de senhas de oficinas, linha 12 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: BP101636', 1
WHERE @portalCredentialId IS NULL;

-- Linha 14
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP123932'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ikhMYQlm+j5uhLbO',
  senhaIv = 'HxiHehtC3onYdF0V',
  senhaTag = 'WOnXRxXPZ0SKsvz/AoOygg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 14 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: BP123932',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP123932', NULL, '-----',
  'ikhMYQlm+j5uhLbO', 'HxiHehtC3onYdF0V', 'WOnXRxXPZ0SKsvz/AoOygg==', 'Origem: planilha de senhas de oficinas, linha 14 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: BP123932', 1
WHERE @portalCredentialId IS NULL;

-- Linha 15
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP119702'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '7tjz3M7CXLorXgwA',
  senhaIv = 'V9eyj+405zqmHjyI',
  senhaTag = 'E1wvilnQecwK+FB42X0T2A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 15 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: BP119702',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP119702', NULL, '-----',
  '7tjz3M7CXLorXgwA', 'V9eyj+405zqmHjyI', 'E1wvilnQecwK+FB42X0T2A==', 'Origem: planilha de senhas de oficinas, linha 15 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: BP119702', 1
WHERE @portalCredentialId IS NULL;

-- Linha 16
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP121048'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'PbtFYY96BE9jM/DJYtI=',
  senhaIv = 'UG6xFzIx+FIjKXhX',
  senhaTag = 'bs3fboUtskBFquKIh4vMmw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 16 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: BP121048',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP121048', NULL, '-----',
  'PbtFYY96BE9jM/DJYtI=', 'UG6xFzIx+FIjKXhX', 'bs3fboUtskBFquKIh4vMmw==', 'Origem: planilha de senhas de oficinas, linha 16 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: BP121048', 1
WHERE @portalCredentialId IS NULL;

-- Linha 17
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP139580'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'pAOYXdiQpbBeozvd',
  senhaIv = 'NWB0Wdp0ziaH2U5v',
  senhaTag = 'w8IVVAvOkCrehkIdZJ2gBQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 17 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Peças Estoque | CNPJ: 46101424002600 | Acesso original: BP139580',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP139580', NULL, '-----',
  'pAOYXdiQpbBeozvd', 'NWB0Wdp0ziaH2U5v', 'w8IVVAvOkCrehkIdZJ2gBQ==', 'Origem: planilha de senhas de oficinas, linha 17 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP Peças Estoque | CNPJ: 46101424002600 | Acesso original: BP139580', 1
WHERE @portalCredentialId IS NULL;

-- Linha 18
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP105839'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'TFBE0pt85SrAbIkT',
  senhaIv = 'tNviW42cNkgnD3Vk',
  senhaTag = '1DYng348TL7cineCnWrSxQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 18 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: BP105839',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP105839', NULL, '-----',
  'TFBE0pt85SrAbIkT', 'tNviW42cNkgnD3Vk', '1DYng348TL7cineCnWrSxQ==', 'Origem: planilha de senhas de oficinas, linha 18 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: BP105839', 1
WHERE @portalCredentialId IS NULL;

-- Linha 19
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP104743'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'PwXo9oHu+biSn8Iy//4=',
  senhaIv = '6hfcwSNrNPapSGlZ',
  senhaTag = 'Rd+P8/GzhaloVK5EDSO8QQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 19 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: BP104743',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP104743', NULL, '-----',
  'PwXo9oHu+biSn8Iy//4=', '6hfcwSNrNPapSGlZ', 'Rd+P8/GzhaloVK5EDSO8QQ==', 'Origem: planilha de senhas de oficinas, linha 19 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: BP104743', 1
WHERE @portalCredentialId IS NULL;

-- Linha 21
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP105845'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'HnNrZekiFgZV9wYC',
  senhaIv = 'u5Pz4uYxxHwZ6zkd',
  senhaTag = 'Iq3xw4E0rxjSL+PB0lW1XQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 21 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: BP105845',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP105845', NULL, '-----',
  'HnNrZekiFgZV9wYC', 'u5Pz4uYxxHwZ6zkd', 'Iq3xw4E0rxjSL+PB0lW1XQ==', 'Origem: planilha de senhas de oficinas, linha 21 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: BP105845', 1
WHERE @portalCredentialId IS NULL;

-- Linha 22
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP121930'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '6mjEGzhD1Peeu1qfCQtj',
  senhaIv = 'Jdnqx2mJEV4zdWSm',
  senhaTag = 'g9+YdvXsEH96rQqoEHn9qQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 22 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: BP121930',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP121930', NULL, '-----',
  '6mjEGzhD1Peeu1qfCQtj', 'Jdnqx2mJEV4zdWSm', 'g9+YdvXsEH96rQqoEHn9qQ==', 'Origem: planilha de senhas de oficinas, linha 22 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: BP121930', 1
WHERE @portalCredentialId IS NULL;

-- Linha 23
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP122146'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sg593lLVu7g0m+x5P3BKWg==',
  senhaIv = 'hnjRTFM/Ji33UbSn',
  senhaTag = 'kz637h6meiWpVJ334fT84w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 23 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: BP122146',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP122146', NULL, '-----',
  'sg593lLVu7g0m+x5P3BKWg==', 'hnjRTFM/Ji33UbSn', 'kz637h6meiWpVJ334fT84w==', 'Origem: planilha de senhas de oficinas, linha 23 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: BP122146', 1
WHERE @portalCredentialId IS NULL;

-- Linha 24
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP105846'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Up93wqHcSsfK9f/D1Q==',
  senhaIv = 'sWNj2ajidH8m8Ukw',
  senhaTag = '7MIqlGXSV5qLCZQYJCAkkg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 24 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: BP105846',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP105846', NULL, '-----',
  'Up93wqHcSsfK9f/D1Q==', 'sWNj2ajidH8m8Ukw', '7MIqlGXSV5qLCZQYJCAkkg==', 'Origem: planilha de senhas de oficinas, linha 24 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: BP105846', 1
WHERE @portalCredentialId IS NULL;

-- Linha 25
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP104744'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '5XcrllgTu6OnzDn92w==',
  senhaIv = '7QD0RkvNNwytn5aB',
  senhaTag = 'p+1g7fQTb92WMtGEV2g9Cw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 25 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: BP104744',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP104744', NULL, '-----',
  '5XcrllgTu6OnzDn92w==', '7QD0RkvNNwytn5aB', 'p+1g7fQTb92WMtGEV2g9Cw==', 'Origem: planilha de senhas de oficinas, linha 25 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: BP104744', 1
WHERE @portalCredentialId IS NULL;

-- Linha 26
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP134570'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '6aDVAbEPivmyuI5dK9Ra3g==',
  senhaIv = 'WYJfDNPGNtR0m1BA',
  senhaTag = 'gDzNQyPQ9QMbwugi2P9GFA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 26 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: BP134570',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP134570', NULL, '-----',
  '6aDVAbEPivmyuI5dK9Ra3g==', 'WYJfDNPGNtR0m1BA', 'gDzNQyPQ9QMbwugi2P9GFA==', 'Origem: planilha de senhas de oficinas, linha 26 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: BP134570', 1
WHERE @portalCredentialId IS NULL;

-- Linha 27
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP118046'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'eK7IRHQgiqhEcCQ=',
  senhaIv = 'Invs/5goAjLnGHja',
  senhaTag = 'ZPGneW47zlvgiaLFgcB+xQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 27 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: BP118046',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP118046', NULL, '-----',
  'eK7IRHQgiqhEcCQ=', 'Invs/5goAjLnGHja', 'ZPGneW47zlvgiaLFgcB+xQ==', 'Origem: planilha de senhas de oficinas, linha 27 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: BP118046', 1
WHERE @portalCredentialId IS NULL;

-- Linha 28
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP110197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Wzg3x2FNC3yIzyarjM/0JA==',
  senhaIv = 'i8auH1+hVFuXluQe',
  senhaTag = '2Gv8lAoG0xrszAUN/rVZ3Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 28 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: BP110197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP110197', NULL, '-----',
  'Wzg3x2FNC3yIzyarjM/0JA==', 'i8auH1+hVFuXluQe', '2Gv8lAoG0xrszAUN/rVZ3Q==', 'Origem: planilha de senhas de oficinas, linha 28 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: BP110197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 29
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP125225'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '7y+jH8N+w0wbOQ==',
  senhaIv = 'vnBH3fgZAxWzbKwE',
  senhaTag = '+X+UD3E/MOma2/s8KAnYOg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 29 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: BP125225',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP125225', NULL, '-----',
  '7y+jH8N+w0wbOQ==', 'vnBH3fgZAxWzbKwE', '+X+UD3E/MOma2/s8KAnYOg==', 'Origem: planilha de senhas de oficinas, linha 29 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: BP125225', 1
WHERE @portalCredentialId IS NULL;

-- Linha 30
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP113704'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'vZnOHupyY6bNbcHa',
  senhaIv = '6UxOqWDM90GMxYXo',
  senhaTag = '1LGeU3+cLFViR6N4uGRdsA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 30 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: BP113704',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP113704', NULL, '-----',
  'vZnOHupyY6bNbcHa', '6UxOqWDM90GMxYXo', '1LGeU3+cLFViR6N4uGRdsA==', 'Origem: planilha de senhas de oficinas, linha 30 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: BP113704', 1
WHERE @portalCredentialId IS NULL;

-- Linha 31
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP132953'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'uikKDNyyQStpEDP+l4M=',
  senhaIv = 'YmujrayRdMYjbhgF',
  senhaTag = 'RJobIT+Wae0hhPOFY/dQ0w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 31 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: BP132953',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP132953', NULL, '-----',
  'uikKDNyyQStpEDP+l4M=', 'YmujrayRdMYjbhgF', 'RJobIT+Wae0hhPOFY/dQ0w==', 'Origem: planilha de senhas de oficinas, linha 31 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: BP132953', 1
WHERE @portalCredentialId IS NULL;

-- Linha 32
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP101907'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Lc+PKjbn43LlH/5j',
  senhaIv = 'SLcj5yC9YUiKxtRI',
  senhaTag = '97dSSmREzdeWoArGK7YV0A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 32 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: BP101907',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP101907', NULL, '-----',
  'Lc+PKjbn43LlH/5j', 'SLcj5yC9YUiKxtRI', '97dSSmREzdeWoArGK7YV0A==', 'Origem: planilha de senhas de oficinas, linha 32 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: BP101907', 1
WHERE @portalCredentialId IS NULL;

-- Linha 33
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP104735'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'yTG4OQv1hXeLNJLOtTA=',
  senhaIv = 'rFE/lAOE78kf5+A3',
  senhaTag = 's0kOk6t1vsRz2LjAgHPQkg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 33 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: BP104735',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP104735', NULL, '-----',
  'yTG4OQv1hXeLNJLOtTA=', 'rFE/lAOE78kf5+A3', 's0kOk6t1vsRz2LjAgHPQkg==', 'Origem: planilha de senhas de oficinas, linha 33 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: BP104735', 1
WHERE @portalCredentialId IS NULL;

-- Linha 34
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP144453'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '6WPEoNxjjn7JildgqA==',
  senhaIv = 'tlWNPmNbhbQdXTBX',
  senhaTag = 'A1Twf0ebR/fDpspUgmBQAw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 34 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL UBERABA | CNPJ: 49226749001384 | Acesso original: BP144453',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP144453', NULL, '-----',
  '6WPEoNxjjn7JildgqA==', 'tlWNPmNbhbQdXTBX', 'A1Twf0ebR/fDpspUgmBQAw==', 'Origem: planilha de senhas de oficinas, linha 34 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: ORTOVEL UBERABA | CNPJ: 49226749001384 | Acesso original: BP144453', 1
WHERE @portalCredentialId IS NULL;

-- Linha 36
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP120093'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '03KLOiRhAQwbmZ49gust',
  senhaIv = '3K7Ofe6PT9JdMLMW',
  senhaTag = 'Hg8mn5vENtcRM5SeuHhqPg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 36 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: BP120093',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP120093', NULL, '-----',
  '03KLOiRhAQwbmZ49gust', '3K7Ofe6PT9JdMLMW', 'Hg8mn5vENtcRM5SeuHhqPg==', 'Origem: planilha de senhas de oficinas, linha 36 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: BP120093', 1
WHERE @portalCredentialId IS NULL;

-- Linha 37
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP120162'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'kOjeTStqjULEpP9V7ThU',
  senhaIv = 'H4sojktyy0tCFUXG',
  senhaTag = 'YMdlw5tYTHiunrq5Bw6FJA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 37 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: BP120162',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP120162', NULL, '-----',
  'kOjeTStqjULEpP9V7ThU', 'H4sojktyy0tCFUXG', 'YMdlw5tYTHiunrq5Bw6FJA==', 'Origem: planilha de senhas de oficinas, linha 37 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: BP120162', 1
WHERE @portalCredentialId IS NULL;

-- Linha 38
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Allianz'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Allianz'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'BP124121'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'j3hoIxUowr1xbD92di4=',
  senhaIv = 'VgdRb5sWgpPA7/XY',
  senhaTag = 'En6/k77Ro9XqWuQMZcxEGQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 38 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: BP124121',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'BP124121', NULL, '-----',
  'j3hoIxUowr1xbD92di4=', 'VgdRb5sWgpPA7/XY', 'En6/k77Ro9XqWuQMZcxEGQ==', 'Origem: planilha de senhas de oficinas, linha 38 | Segmento: FORNECIMENTO | Seguradora: ALLIANZ (FRN Direto) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: BP124121', 1
WHERE @portalCredentialId IS NULL;

-- Linha 39
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001468'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'VpAEoIo16Pu0aV0=',
  senhaIv = 'am5tPkRpxTRPe6Aj',
  senhaTag = 'IpL3wmZGImgGLSg1j0RboA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 39 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001468', NULL, '-----',
  'VpAEoIo16Pu0aV0=', 'am5tPkRpxTRPe6Aj', 'IpL3wmZGImgGLSg1j0RboA==', 'Origem: planilha de senhas de oficinas, linha 39 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468', 1
WHERE @portalCredentialId IS NULL;

-- Linha 40
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001387'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '0b7hk1T+CbAX5g==',
  senhaIv = 'OrQvtFl9rMiFEpxz',
  senhaTag = 'xh27PAj9ifX5LCbvASsjmg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 40 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001387', NULL, '-----',
  '0b7hk1T+CbAX5g==', 'OrQvtFl9rMiFEpxz', 'xh27PAj9ifX5LCbvASsjmg==', 'Origem: planilha de senhas de oficinas, linha 40 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387', 1
WHERE @portalCredentialId IS NULL;

-- Linha 41
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424000143'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'XVqu+WkJRLY2/is=',
  senhaIv = 'Qu6LasAH3RoUZAca',
  senhaTag = '5unGwqLXSDPqHF7KHXqHGQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 41 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424000143', NULL, '-----',
  'XVqu+WkJRLY2/is=', 'Qu6LasAH3RoUZAca', '5unGwqLXSDPqHF7KHXqHGQ==', 'Origem: planilha de senhas de oficinas, linha 41 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143', 1
WHERE @portalCredentialId IS NULL;

-- Linha 42
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001549'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'dK+iv+c=',
  senhaIv = 'Xqqp7FFVOrf7Ov2B',
  senhaTag = 'dtG4kXGRr8Ee2N5GWtt/2g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 42 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001549', NULL, '-----',
  'dK+iv+c=', 'Xqqp7FFVOrf7Ov2B', 'dtG4kXGRr8Ee2N5GWtt/2g==', 'Origem: planilha de senhas de oficinas, linha 42 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549', 1
WHERE @portalCredentialId IS NULL;

-- Linha 43
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000125'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'hxqHu9k=',
  senhaIv = 'WuUWIlTffs6qbPmZ',
  senhaTag = '+Ynn3up2XbdaFH8iYArgIQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 43 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000125', NULL, '-----',
  'hxqHu9k=', 'WuUWIlTffs6qbPmZ', '+Ynn3up2XbdaFH8iYArgIQ==', 'Origem: planilha de senhas de oficinas, linha 43 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125', 1
WHERE @portalCredentialId IS NULL;

-- Linha 44
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000206'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'eiJDJMVUpnAD',
  senhaIv = 'qNc9cz9c2jOq0Eyt',
  senhaTag = '93eZybZvcW3+o/tYrhPihQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 44 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000206', NULL, '-----',
  'eiJDJMVUpnAD', 'qNc9cz9c2jOq0Eyt', '93eZybZvcW3+o/tYrhPihQ==', 'Origem: planilha de senhas de oficinas, linha 44 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206', 1
WHERE @portalCredentialId IS NULL;

-- Linha 45
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00 384141000902'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zq2u2sWJVG4lbMZ9hA==',
  senhaIv = 'ytfmtiBYAZ0cG2Xp',
  senhaTag = 'TPHTARpy3P8K1zJPsjAqyg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 45 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00 384141000902',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00 384141000902', NULL, '-----',
  'zq2u2sWJVG4lbMZ9hA==', 'ytfmtiBYAZ0cG2Xp', 'TPHTARpy3P8K1zJPsjAqyg==', 'Origem: planilha de senhas de oficinas, linha 45 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00 384141000902', 1
WHERE @portalCredentialId IS NULL;

-- Linha 46
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00 384141000155'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '76JHm+tVJ0nD',
  senhaIv = 'txUp8Rd8WIz201aJ',
  senhaTag = 'fzXG6Rk6KIV5I2BjUBJVzA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 46 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00 384141000155',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00 384141000155', NULL, '-----',
  '76JHm+tVJ0nD', 'txUp8Rd8WIz201aJ', 'fzXG6Rk6KIV5I2BjUBJVzA==', 'Origem: planilha de senhas de oficinas, linha 46 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00 384141000155', 1
WHERE @portalCredentialId IS NULL;

-- Linha 47
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'FcQRAp8=',
  senhaIv = 'du1pE1LUdc0OAqdo',
  senhaTag = '85hr8wslwzQpbkq+Tri7Ig==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 47 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002197', NULL, '-----',
  'FcQRAp8=', 'du1pE1LUdc0OAqdo', '85hr8wslwzQpbkq+Tri7Ig==', 'Origem: planilha de senhas de oficinas, linha 47 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 48
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002359'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '3WD8yvkXp81aDA==',
  senhaIv = '6CM0iE5d8Eupqu1E',
  senhaTag = 'IfKx7bq3sVP/CdjXEqnY0A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 48 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002359', NULL, '-----',
  '3WD8yvkXp81aDA==', '6CM0iE5d8Eupqu1E', 'IfKx7bq3sVP/CdjXEqnY0A==', 'Origem: planilha de senhas de oficinas, linha 48 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359', 1
WHERE @portalCredentialId IS NULL;

-- Linha 49
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001891'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'vg+3Yyi7ksMe5A==',
  senhaIv = 'gcx8spy9JRGN4T5Y',
  senhaTag = 'Wd18VIpYLxaM/qInNQcH4g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 49 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001891', NULL, '-----',
  'vg+3Yyi7ksMe5A==', 'gcx8spy9JRGN4T5Y', 'Wd18VIpYLxaM/qInNQcH4g==', 'Origem: planilha de senhas de oficinas, linha 49 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891', 1
WHERE @portalCredentialId IS NULL;

-- Linha 50
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'miiX4tW6xNJ99AEVK+w=',
  senhaIv = 'Vd+v4ACPtP23Aa5w',
  senhaTag = 'oVc5UASmyweNJGRtGfmhMg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 50 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'miiX4tW6xNJ99AEVK+w=', 'Vd+v4ACPtP23Aa5w', 'oVc5UASmyweNJGRtGfmhMg==', 'Origem: planilha de senhas de oficinas, linha 50 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 51
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000421'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '/Sk/rMw1Tu4=',
  senhaIv = 'Z2kXdl6TP5gDDzTu',
  senhaTag = 'T3tyETxKP66c50Q/AAh+zQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 51 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000421', NULL, '-----',
  '/Sk/rMw1Tu4=', 'Z2kXdl6TP5gDDzTu', 'T3tyETxKP66c50Q/AAh+zQ==', 'Origem: planilha de senhas de oficinas, linha 51 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421', 1
WHERE @portalCredentialId IS NULL;

-- Linha 52
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000693'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'l+ou+Wwv3ulD',
  senhaIv = 'XGnfuRI3ycc6dJrm',
  senhaTag = 'sbqId0Kh9j0GrXb6eC9lIg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 52 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000693', NULL, '-----',
  'l+ou+Wwv3ulD', 'XGnfuRI3ycc6dJrm', 'sbqId0Kh9j0GrXb6eC9lIg==', 'Origem: planilha de senhas de oficinas, linha 52 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693', 1
WHERE @portalCredentialId IS NULL;

-- Linha 53
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000340'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'i2g4aKZ1IJ0=',
  senhaIv = 'I9C1rfxMUpM1Q/nX',
  senhaTag = 'Omi4SzWK163JEoBiNPq2Pg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 53 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000340', NULL, '-----',
  'i2g4aKZ1IJ0=', 'I9C1rfxMUpM1Q/nX', 'Omi4SzWK163JEoBiNPq2Pg==', 'Origem: planilha de senhas de oficinas, linha 53 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340', 1
WHERE @portalCredentialId IS NULL;

-- Linha 54
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000260'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '9m30bA+zsM4=',
  senhaIv = '4yJFiGfLyg+dPhMz',
  senhaTag = '8O4Ps+A3eWVrZWMGx/GtWQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 54 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000260', NULL, '-----',
  '9m30bA+zsM4=', '4yJFiGfLyg+dPhMz', '8O4Ps+A3eWVrZWMGx/GtWQ==', 'Origem: planilha de senhas de oficinas, linha 54 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260', 1
WHERE @portalCredentialId IS NULL;

-- Linha 55
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'meBhU7aksaM=',
  senhaIv = '8qtcBfwM231UEkRy',
  senhaTag = 'OaIASoZL+8J33XjmhfQ0rQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 55 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'meBhU7aksaM=', '8qtcBfwM231UEkRy', 'OaIASoZL+8J33XjmhfQ0rQ==', 'Origem: planilha de senhas de oficinas, linha 55 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 57
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000225'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sU3VTORVh2gX',
  senhaIv = 'DS01LGqDxGtcQPHM',
  senhaTag = 'BuARBEqAcmGUfyC/HjP9hw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 57 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000225', NULL, '-----',
  'sU3VTORVh2gX', 'DS01LGqDxGtcQPHM', 'BuARBEqAcmGUfyC/HjP9hw==', 'Origem: planilha de senhas de oficinas, linha 57 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225', 1
WHERE @portalCredentialId IS NULL;

-- Linha 58
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000144'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'uKxL/Kiqk6s=',
  senhaIv = 'S4sbZCT3NnWRdtzj',
  senhaTag = 'H6W4PJVNbgG2VZGLObCULg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 58 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000144', NULL, '-----',
  'uKxL/Kiqk6s=', 'S4sbZCT3NnWRdtzj', 'H6W4PJVNbgG2VZGLObCULg==', 'Origem: planilha de senhas de oficinas, linha 58 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144', 1
WHERE @portalCredentialId IS NULL;

-- Linha 59
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000477'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'MR19gFOCwfp0Hw==',
  senhaIv = 'EvxozruxHoz8FSpI',
  senhaTag = 'r3Geoq5ai8wOjP34hEIFkQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 59 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000477', NULL, '-----',
  'MR19gFOCwfp0Hw==', 'EvxozruxHoz8FSpI', 'r3Geoq5ai8wOjP34hEIFkQ==', 'Origem: planilha de senhas de oficinas, linha 59 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477', 1
WHERE @portalCredentialId IS NULL;

-- Linha 60
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000396'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ILQN+ZE=',
  senhaIv = 'eYX07l3p8BW+NvfS',
  senhaTag = 'W5a5lDjBp2vQBp1VCjVkrg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 60 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 24896001000396',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000396', NULL, '-----',
  'ILQN+ZE=', 'eYX07l3p8BW+NvfS', 'W5a5lDjBp2vQBp1VCjVkrg==', 'Origem: planilha de senhas de oficinas, linha 60 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 24896001000396', 1
WHERE @portalCredentialId IS NULL;

-- Linha 61
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000124'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '92xkkkbrLzUaNcY/',
  senhaIv = 'RotrARcAQ/DJFWok',
  senhaTag = 'cBeiAf0VAOj9viqpg3g1mQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 61 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000124', NULL, '-----',
  '92xkkkbrLzUaNcY/', 'RotrARcAQ/DJFWok', 'cBeiAf0VAOj9viqpg3g1mQ==', 'Origem: planilha de senhas de oficinas, linha 61 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124', 1
WHERE @portalCredentialId IS NULL;

-- Linha 62
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749001201'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'KZ4wYrS5hBIyQw==',
  senhaIv = 'eR39jbKi6Q9TvPTQ',
  senhaTag = 'BJQuqD3d4mwO4+WKbd5ACg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 62 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 49226749001201',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749001201', NULL, '-----',
  'KZ4wYrS5hBIyQw==', 'eR39jbKi6Q9TvPTQ', 'BJQuqD3d4mwO4+WKbd5ACg==', 'Origem: planilha de senhas de oficinas, linha 62 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 49226749001201', 1
WHERE @portalCredentialId IS NULL;

-- Linha 63
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000140'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'MFnIbPq1nQH9',
  senhaIv = 'MiQp2H75kO6rduFl',
  senhaTag = 'J8TTqibiCkP/Yf9iU13HRg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 63 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000140', NULL, '-----',
  'MFnIbPq1nQH9', 'MiQp2H75kO6rduFl', 'J8TTqibiCkP/Yf9iU13HRg==', 'Origem: planilha de senhas de oficinas, linha 63 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140', 1
WHERE @portalCredentialId IS NULL;

-- Linha 64
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000736'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'x/eIoIPlcM2H8g==',
  senhaIv = 'ms7IwUJy2I1gz14+',
  senhaTag = '/qai6G+tX134/2iTZKB+0w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 64 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000736', NULL, '-----',
  'x/eIoIPlcM2H8g==', 'ms7IwUJy2I1gz14+', '/qai6G+tX134/2iTZKB+0w==', 'Origem: planilha de senhas de oficinas, linha 64 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736', 1
WHERE @portalCredentialId IS NULL;

-- Linha 65
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000169'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'mv8o9Ju+6pUP',
  senhaIv = 'xVYDMBPCvqHf9xv2',
  senhaTag = '+Ho2+MV1uDAqkqxvdsFtow==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 65 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000169', NULL, '-----',
  'mv8o9Ju+6pUP', 'xVYDMBPCvqHf9xv2', '+Ho2+MV1uDAqkqxvdsFtow==', 'Origem: planilha de senhas de oficinas, linha 65 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169', 1
WHERE @portalCredentialId IS NULL;

-- Linha 66
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Azul'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Azul'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000240'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Hd0eNVc=',
  senhaIv = '2J4/RfL+WtUUM09j',
  senhaTag = 'rgFrH6qPBb2C0OpSCPtXPQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 66 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000240', NULL, '-----',
  'Hd0eNVc=', '2J4/RfL+WtUUM09j', 'rgFrH6qPBb2C0OpSCPtXPQ==', 'Origem: planilha de senhas de oficinas, linha 66 | Segmento: OFICINA | Seguradora: AZUL (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240', 1
WHERE @portalCredentialId IS NULL;

-- Linha 67
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Essor'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Essor'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002359'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'MwUvKrMGdYDg3g==',
  senhaIv = 'LcHtq7psZ33MqVOi',
  senhaTag = 'VIVFrGnVVbQuSDgZhITn1A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 67 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002359', NULL, '-----',
  'MwUvKrMGdYDg3g==', 'LcHtq7psZ33MqVOi', 'VIVFrGnVVbQuSDgZhITn1A==', 'Origem: planilha de senhas de oficinas, linha 67 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359', 1
WHERE @portalCredentialId IS NULL;

-- Linha 68
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Essor'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Essor'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'nTN3a7JeJHKbeBLArg==',
  senhaIv = 'p5/gtCFJSd1j0ryJ',
  senhaTag = 'afKF2mXWbgkmV9KiUNxKWg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 68 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'nTN3a7JeJHKbeBLArg==', 'p5/gtCFJSd1j0ryJ', 'afKF2mXWbgkmV9KiUNxKWg==', 'Origem: planilha de senhas de oficinas, linha 68 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 70
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Essor'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Essor'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'QQxqA7s3uR5RVcjmoA==',
  senhaIv = 'HEn0joFSpsX4aZTt',
  senhaTag = 'OWWodJmZiO6qwz9X2zQ1yw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 70 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'QQxqA7s3uR5RVcjmoA==', 'HEn0joFSpsX4aZTt', 'OWWodJmZiO6qwz9X2zQ1yw==', 'Origem: planilha de senhas de oficinas, linha 70 | Segmento: OFICINA | Seguradora: ESSOR (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 72
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'Seguradora'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'HOBXs/e631Q=',
  senhaIv = 'LCoYERfN6McGlcSe',
  senhaTag = 'ploZyvu8nzsxmNTGVt+S7Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 72 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: Seguradora',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'Seguradora', NULL, '-----',
  'HOBXs/e631Q=', 'LCoYERfN6McGlcSe', 'ploZyvu8nzsxmNTGVt+S7Q==', 'Origem: planilha de senhas de oficinas, linha 72 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: Seguradora', 1
WHERE @portalCredentialId IS NULL;

-- Linha 73
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA8'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '34zApQHju1E=',
  senhaIv = '82yjfWhB2w96HbZp',
  senhaTag = 'RX5cVpmeO0gR7D120xEvQw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 73 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: SEGURADORA8',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA8', NULL, '-----',
  '34zApQHju1E=', '82yjfWhB2w96HbZp', 'RX5cVpmeO0gR7D120xEvQw==', 'Origem: planilha de senhas de oficinas, linha 73 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: SEGURADORA8', 1
WHERE @portalCredentialId IS NULL;

-- Linha 74
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA3'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'hjWEpvXDoZg=',
  senhaIv = '17IgvZKOVJWVO/qn',
  senhaTag = 'j4dAHfqoJc1CsUcBDQ6nkg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 74 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: SEGURADORA3',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA3', NULL, '-----',
  'hjWEpvXDoZg=', '17IgvZKOVJWVO/qn', 'j4dAHfqoJc1CsUcBDQ6nkg==', 'Origem: planilha de senhas de oficinas, linha 74 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: SEGURADORA3', 1
WHERE @portalCredentialId IS NULL;

-- Linha 75
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA7'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Ap10rSkPpIo=',
  senhaIv = 'R+Ugc93ev8h7ygTb',
  senhaTag = 'mVTnhTj8FZt6EU4Rv4ZVnA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 75 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: SEGURADORA7',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA7', NULL, '-----',
  'Ap10rSkPpIo=', 'R+Ugc93ev8h7ygTb', 'mVTnhTj8FZt6EU4Rv4ZVnA==', 'Origem: planilha de senhas de oficinas, linha 75 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: SEGURADORA7', 1
WHERE @portalCredentialId IS NULL;

-- Linha 76
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'NgtC1POUbZM=',
  senhaIv = '8ls1IWxPl46JMoWe',
  senhaTag = 'S+Tno5FuM6a0aGtkYV3PNg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 76 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: SEGURADORA',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA', NULL, '-----',
  'NgtC1POUbZM=', '8ls1IWxPl46JMoWe', 'S+Tno5FuM6a0aGtkYV3PNg==', 'Origem: planilha de senhas de oficinas, linha 76 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: SEGURADORA', 1
WHERE @portalCredentialId IS NULL;

-- Linha 77
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA4'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'lwwACPE9bWY=',
  senhaIv = 'VI9700NCATzUYScy',
  senhaTag = 'dGnFILrfqBFrtnETmj01pQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 77 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: SEGURADORA4',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA4', NULL, '-----',
  'lwwACPE9bWY=', 'VI9700NCATzUYScy', 'dGnFILrfqBFrtnETmj01pQ==', 'Origem: planilha de senhas de oficinas, linha 77 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: SEGURADORA4', 1
WHERE @portalCredentialId IS NULL;

-- Linha 78
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA2'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '7hao4oVGRDU=',
  senhaIv = 'qiaBXBARnR9jvuc3',
  senhaTag = 'aKFgaKoa+8wQyjNhAZEOew==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 78 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: SEGURADORA2',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA2', NULL, '-----',
  '7hao4oVGRDU=', 'qiaBXBARnR9jvuc3', 'aKFgaKoa+8wQyjNhAZEOew==', 'Origem: planilha de senhas de oficinas, linha 78 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: SEGURADORA2', 1
WHERE @portalCredentialId IS NULL;

-- Linha 79
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA9'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'oy/I7AoWpac=',
  senhaIv = 'bhTHsel3vYoDUFwq',
  senhaTag = '81zkLjejicc56ukNTG6xBg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 79 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: SEGURADORA9',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA9', NULL, '-----',
  'oy/I7AoWpac=', 'bhTHsel3vYoDUFwq', '81zkLjejicc56ukNTG6xBg==', 'Origem: planilha de senhas de oficinas, linha 79 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: SEGURADORA9', 1
WHERE @portalCredentialId IS NULL;

-- Linha 80
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA6'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'hVktGJErGqc=',
  senhaIv = 'dBAXstPetwPSeX+N',
  senhaTag = 'o2czZKij7vPBrsMltI3Kug==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 80 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: SEGURADORA6',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA6', NULL, '-----',
  'hVktGJErGqc=', 'dBAXstPetwPSeX+N', 'o2czZKij7vPBrsMltI3Kug==', 'Origem: planilha de senhas de oficinas, linha 80 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: SEGURADORA6', 1
WHERE @portalCredentialId IS NULL;

-- Linha 81
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA1'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ItiV9s1+6Og=',
  senhaIv = '47iuVuXHHcaLJ8V+',
  senhaTag = 'KicDF3KtydQ2co2YaWlHiQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 81 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: SEGURADORA1',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA1', NULL, '-----',
  'ItiV9s1+6Og=', '47iuVuXHHcaLJ8V+', 'KicDF3KtydQ2co2YaWlHiQ==', 'Origem: planilha de senhas de oficinas, linha 81 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: SEGURADORA1', 1
WHERE @portalCredentialId IS NULL;

-- Linha 82
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Generali'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Generali'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'SEGURADORA5'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'P3XEF4ALQk0=',
  senhaIv = 'ko458j7Dvb1KaF0g',
  senhaTag = 'xJFO7BDc5WOQFZr9HIbgPg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 82 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: SEGURADORA5',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'SEGURADORA5', NULL, '-----',
  'P3XEF4ALQk0=', 'ko458j7Dvb1KaF0g', 'xJFO7BDc5WOQFZr9HIbgPg==', 'Origem: planilha de senhas de oficinas, linha 82 | Segmento: OFICINA | Seguradora: GENERALI (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: SEGURADORA5', 1
WHERE @portalCredentialId IS NULL;

-- Linha 83
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001468'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zgqxyys=',
  senhaIv = 'lJ9JYf7GGxzxHxzF',
  senhaTag = '1+HLLqJiy5qkqMo/vjqiqg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 83 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001468', NULL, '-----',
  'zgqxyys=', 'lJ9JYf7GGxzxHxzF', '1+HLLqJiy5qkqMo/vjqiqg==', 'Origem: planilha de senhas de oficinas, linha 83 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468', 1
WHERE @portalCredentialId IS NULL;

-- Linha 84
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '44453371888'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'fzK7hFjOMJeYUnDL93FZ',
  senhaIv = 'p6CGMhXFSaL8hDLL',
  senhaTag = 'AAeMSh3w5xSYRcFj+Qbpnw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 84 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 44453371888',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '44453371888', NULL, '-----',
  'fzK7hFjOMJeYUnDL93FZ', 'p6CGMhXFSaL8hDLL', 'AAeMSh3w5xSYRcFj+Qbpnw==', 'Origem: planilha de senhas de oficinas, linha 84 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 44453371888', 1
WHERE @portalCredentialId IS NULL;

-- Linha 85
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424000143'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'yD3D1R8=',
  senhaIv = 'ZrXDbIqKTStdzhTJ',
  senhaTag = 'HZykHr5exto8LxMJhszLVQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 85 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424000143', NULL, '-----',
  'yD3D1R8=', 'ZrXDbIqKTStdzhTJ', 'HZykHr5exto8LxMJhszLVQ==', 'Origem: planilha de senhas de oficinas, linha 85 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143', 1
WHERE @portalCredentialId IS NULL;

-- Linha 86
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001549'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'A/RNRNm8iaBD',
  senhaIv = 'XTk0Ns7n0XeGG4Mo',
  senhaTag = '0C6zZFHOd2296andBQDATQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 86 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001549', NULL, '-----',
  'A/RNRNm8iaBD', 'XTk0Ns7n0XeGG4Mo', '0C6zZFHOd2296andBQDATQ==', 'Origem: planilha de senhas de oficinas, linha 86 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549', 1
WHERE @portalCredentialId IS NULL;

-- Linha 87
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000125'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'i3tio1s=',
  senhaIv = 'UTDQaeM/CnP1qv0h',
  senhaTag = '69Xk8NFU+bDEYEHkPNat5A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 87 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000125', NULL, '-----',
  'i3tio1s=', 'UTDQaeM/CnP1qv0h', '69Xk8NFU+bDEYEHkPNat5A==', 'Origem: planilha de senhas de oficinas, linha 87 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125', 1
WHERE @portalCredentialId IS NULL;

-- Linha 88
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000206'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'cMlA1CQ=',
  senhaIv = 'H6/2OHopt+BSjE92',
  senhaTag = '2PrPwhZQC0OtQ5ZGiFx6Yw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 88 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000206', NULL, '-----',
  'cMlA1CQ=', 'H6/2OHopt+BSjE92', '2PrPwhZQC0OtQ5ZGiFx6Yw==', 'Origem: planilha de senhas de oficinas, linha 88 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206', 1
WHERE @portalCredentialId IS NULL;

-- Linha 89
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00384141000902'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'QQLTamA=',
  senhaIv = 'JBiD/7XB7jFI3fTc',
  senhaTag = 'BfB7tPPv1sYjBFDgvp7KWQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 89 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00384141000902',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00384141000902', NULL, '-----',
  'QQLTamA=', 'JBiD/7XB7jFI3fTc', 'BfB7tPPv1sYjBFDgvp7KWQ==', 'Origem: planilha de senhas de oficinas, linha 89 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00384141000902', 1
WHERE @portalCredentialId IS NULL;

-- Linha 90
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00384141000155'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WviOfuZAsOk=',
  senhaIv = 'm7j/14wxAkaZGouE',
  senhaTag = 'DrZfrzWyUeI5MrrHbgpw2g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 90 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00384141000155', NULL, '-----',
  'WviOfuZAsOk=', 'm7j/14wxAkaZGouE', 'DrZfrzWyUeI5MrrHbgpw2g==', 'Origem: planilha de senhas de oficinas, linha 90 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155', 1
WHERE @portalCredentialId IS NULL;

-- Linha 91
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'b8euGjo=',
  senhaIv = 'Tm/WXbE1NVv5iUN7',
  senhaTag = 'YhpXr22/g3eRAzembQKnKw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 91 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002197', NULL, '-----',
  'b8euGjo=', 'Tm/WXbE1NVv5iUN7', 'YhpXr22/g3eRAzembQKnKw==', 'Origem: planilha de senhas de oficinas, linha 91 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 92
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001891'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ky92xSg=',
  senhaIv = '6BDF1NLTlxlnp/Ou',
  senhaTag = '/cq1OO1fDj0hlNtn3em32g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 92 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001891', NULL, '-----',
  'ky92xSg=', '6BDF1NLTlxlnp/Ou', '/cq1OO1fDj0hlNtn3em32g==', 'Origem: planilha de senhas de oficinas, linha 92 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891', 1
WHERE @portalCredentialId IS NULL;

-- Linha 93
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'His5vrdf8r4=',
  senhaIv = 'FUzDk9Hh+11vYHNg',
  senhaTag = '6gtdRVCInVwfBO4Hhv1CrQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 93 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'His5vrdf8r4=', 'FUzDk9Hh+11vYHNg', '6gtdRVCInVwfBO4Hhv1CrQ==', 'Origem: planilha de senhas de oficinas, linha 93 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 94
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000421'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'jyK3n7HwyhQ=',
  senhaIv = 'trh2py7mr7HwX5nG',
  senhaTag = 'PihjFLpjAec9a1n7KJ2DNg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 94 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000421', NULL, '-----',
  'jyK3n7HwyhQ=', 'trh2py7mr7HwX5nG', 'PihjFLpjAec9a1n7KJ2DNg==', 'Origem: planilha de senhas de oficinas, linha 94 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421', 1
WHERE @portalCredentialId IS NULL;

-- Linha 95
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000340'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '5qO/7b8=',
  senhaIv = 'jFyie91JqrYfqN7X',
  senhaTag = 'XAUqGIAIaRRdtSsSFtQbbw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 95 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000340', NULL, '-----',
  '5qO/7b8=', 'jFyie91JqrYfqN7X', 'XAUqGIAIaRRdtSsSFtQbbw==', 'Origem: planilha de senhas de oficinas, linha 95 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340', 1
WHERE @portalCredentialId IS NULL;

-- Linha 96
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'raissa.ferreira@atri.com.br'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'raissa.ferreira@atri.com.br',
  senhaCriptografada = 'dKwvMJzru7VQ0WSy',
  senhaIv = 'BDVJYIlhcEKxPsHB',
  senhaTag = 'FaACk4yue6sU2oAqvfkxJw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 96 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: raissa.ferreira@atri.com.br',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'raissa.ferreira@atri.com.br', 'raissa.ferreira@atri.com.br', '-----',
  'dKwvMJzru7VQ0WSy', 'BDVJYIlhcEKxPsHB', 'FaACk4yue6sU2oAqvfkxJw==', 'Origem: planilha de senhas de oficinas, linha 96 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: raissa.ferreira@atri.com.br', 1
WHERE @portalCredentialId IS NULL;

-- Linha 97
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'dz420HWvOBc=',
  senhaIv = 'meUFWMY/ySPpep8C',
  senhaTag = 'V6VcEkR7TOwxVe+deMiZ7Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 97 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'dz420HWvOBc=', 'meUFWMY/ySPpep8C', 'V6VcEkR7TOwxVe+deMiZ7Q==', 'Origem: planilha de senhas de oficinas, linha 97 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 98
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000225'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '1CkJFZ8=',
  senhaIv = 'eeOnFHyL4bQlm3Ao',
  senhaTag = '9xzKWwV3mwZgnNk8i01Hiw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 98 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000225', NULL, '-----',
  '1CkJFZ8=', 'eeOnFHyL4bQlm3Ao', '9xzKWwV3mwZgnNk8i01Hiw==', 'Origem: planilha de senhas de oficinas, linha 98 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225', 1
WHERE @portalCredentialId IS NULL;

-- Linha 99
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000144'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '2O7IC6YrT2I=',
  senhaIv = 'eGBSl/j5WoyOev0w',
  senhaTag = '8DT0rJ1IIjxRDypaynFubA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 99 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000144', NULL, '-----',
  '2O7IC6YrT2I=', 'eGBSl/j5WoyOev0w', '8DT0rJ1IIjxRDypaynFubA==', 'Origem: planilha de senhas de oficinas, linha 99 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144', 1
WHERE @portalCredentialId IS NULL;

-- Linha 100
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'heliton.lima@newhb.com.br'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'heliton.lima@newhb.com.br',
  senhaCriptografada = 'cqcwDo3h+fMBJ2A=',
  senhaIv = 'yfKMqf2ICrniGHUF',
  senhaTag = 'L57B07yp2sDVTMgIduVPjg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 100 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: heliton.lima@newhb.com.br',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'heliton.lima@newhb.com.br', 'heliton.lima@newhb.com.br', '-----',
  'cqcwDo3h+fMBJ2A=', 'yfKMqf2ICrniGHUF', 'L57B07yp2sDVTMgIduVPjg==', 'Origem: planilha de senhas de oficinas, linha 100 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: heliton.lima@newhb.com.br', 1
WHERE @portalCredentialId IS NULL;

-- Linha 101
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000396'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ldj/bCs=',
  senhaIv = 'vwJ+Rr+caVhu9jsf',
  senhaTag = 'imwpocGYDdyI6EGqyeNu/g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 101 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 24896001000396',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000396', NULL, '-----',
  'ldj/bCs=', 'vwJ+Rr+caVhu9jsf', 'imwpocGYDdyI6EGqyeNu/g==', 'Origem: planilha de senhas de oficinas, linha 101 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 24896001000396', 1
WHERE @portalCredentialId IS NULL;

-- Linha 102
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000124'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'TbKIARo=',
  senhaIv = '4Z3Flxsw+YWXaHlO',
  senhaTag = '9DGy3D1LcdSQxAeRWX9Gnw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 102 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000124', NULL, '-----',
  'TbKIARo=', '4Z3Flxsw+YWXaHlO', '9DGy3D1LcdSQxAeRWX9Gnw==', 'Origem: planilha de senhas de oficinas, linha 102 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124', 1
WHERE @portalCredentialId IS NULL;

-- Linha 103
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000140'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'UJr+IuU=',
  senhaIv = 'uDsvFDbvviR4ADfJ',
  senhaTag = 'dteX9JV/RKnK/bnyuDCaLQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 103 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000140', NULL, '-----',
  'UJr+IuU=', 'uDsvFDbvviR4ADfJ', 'dteX9JV/RKnK/bnyuDCaLQ==', 'Origem: planilha de senhas de oficinas, linha 103 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140', 1
WHERE @portalCredentialId IS NULL;

-- Linha 104
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000736'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WiIck8U=',
  senhaIv = 'ye5OHnAcvydWuUTI',
  senhaTag = '0O4SO1FgsgivEyNa3qkMEQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 104 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000736', NULL, '-----',
  'WiIck8U=', 'ye5OHnAcvydWuUTI', '0O4SO1FgsgivEyNa3qkMEQ==', 'Origem: planilha de senhas de oficinas, linha 104 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736', 1
WHERE @portalCredentialId IS NULL;

-- Linha 105
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000169'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'aDtVdDk=',
  senhaIv = 'HYL2YJ8KI/yfcAH4',
  senhaTag = 'Ik9lrvEm227l8nocoYE19A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 105 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000169', NULL, '-----',
  'aDtVdDk=', 'HYL2YJ8KI/yfcAH4', 'Ik9lrvEm227l8nocoYE19A==', 'Origem: planilha de senhas de oficinas, linha 105 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169', 1
WHERE @portalCredentialId IS NULL;

-- Linha 106
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Gente'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Gente'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000240'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sbF9GLQDtvI=',
  senhaIv = 'PyEa/NzwIRKEW69D',
  senhaTag = 'lDDGCKaiA0BqvE+iZ/8DEw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 106 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000240', NULL, '-----',
  'sbF9GLQDtvI=', 'PyEa/NzwIRKEW69D', 'lDDGCKaiA0BqvE+iZ/8DEw==', 'Origem: planilha de senhas de oficinas, linha 106 | Segmento: OFICINA | Seguradora: GENTE (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240', 1
WHERE @portalCredentialId IS NULL;

-- Linha 107
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '27596439000185'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'kWjwzgGZvuk=',
  senhaIv = 'rDM1ZrvonXjSrq9t',
  senhaTag = 'XlIfsaZ0VJj1BVLFV8mkOA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 107 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '27596439000185', NULL, '-----',
  'kWjwzgGZvuk=', 'rDM1ZrvonXjSrq9t', 'XlIfsaZ0VJj1BVLFV8mkOA==', 'Origem: planilha de senhas de oficinas, linha 107 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185', 1
WHERE @portalCredentialId IS NULL;

-- Linha 108
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001468'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '2BQ5mNp/XLKWSDBV3A==',
  senhaIv = '/pAmk1nXa/9su+Z/',
  senhaTag = 'HqHIOkuC0BNgSzVucYe4Mw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 108 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001468', NULL, '-----',
  '2BQ5mNp/XLKWSDBV3A==', '/pAmk1nXa/9su+Z/', 'HqHIOkuC0BNgSzVucYe4Mw==', 'Origem: planilha de senhas de oficinas, linha 108 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 46101424001468', 1
WHERE @portalCredentialId IS NULL;

-- Linha 109
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001387'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'P9y/rEoGaUA=',
  senhaIv = 'N1GftHYfT8zRDROm',
  senhaTag = 'rQOgq6GKPngYXyJ0J00jOA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 109 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001387', NULL, '-----',
  'P9y/rEoGaUA=', 'N1GftHYfT8zRDROm', 'rQOgq6GKPngYXyJ0J00jOA==', 'Origem: planilha de senhas de oficinas, linha 109 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387', 1
WHERE @portalCredentialId IS NULL;

-- Linha 110
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424000143'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'MEn/ShqB3urKEhs=',
  senhaIv = 's526JJtuQT0pIm5d',
  senhaTag = '46xKvDE798mp3mNEQVLBAw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 110 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424000143', NULL, '-----',
  'MEn/ShqB3urKEhs=', 's526JJtuQT0pIm5d', '46xKvDE798mp3mNEQVLBAw==', 'Origem: planilha de senhas de oficinas, linha 110 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143', 1
WHERE @portalCredentialId IS NULL;

-- Linha 111
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001549'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'aXMOaruFUbqn9uaX',
  senhaIv = '39y607BPpjxbf7Os',
  senhaTag = 'QMfLyLv6mvwa+SZ0EASVSQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 111 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001549', NULL, '-----',
  'aXMOaruFUbqn9uaX', '39y607BPpjxbf7Os', 'QMfLyLv6mvwa+SZ0EASVSQ==', 'Origem: planilha de senhas de oficinas, linha 111 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549', 1
WHERE @portalCredentialId IS NULL;

-- Linha 112
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000125'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'LIehkUA/2wwBnCA/qg==',
  senhaIv = 'MGnMkME2dZgtwKFm',
  senhaTag = 'Pl79aXY0dBSsABOn0dTxqw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 112 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000125', NULL, '-----',
  'LIehkUA/2wwBnCA/qg==', 'MGnMkME2dZgtwKFm', 'Pl79aXY0dBSsABOn0dTxqw==', 'Origem: planilha de senhas de oficinas, linha 112 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 22220764000125', 1
WHERE @portalCredentialId IS NULL;

-- Linha 113
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000206'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'nOJJIfNBMKOz9XF1',
  senhaIv = 'fnGU3kmocgHimobu',
  senhaTag = '5lTvCoBsPjDcrRpgPCWP9g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 113 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000206', NULL, '-----',
  'nOJJIfNBMKOz9XF1', 'fnGU3kmocgHimobu', '5lTvCoBsPjDcrRpgPCWP9g==', 'Origem: planilha de senhas de oficinas, linha 113 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206', 1
WHERE @portalCredentialId IS NULL;

-- Linha 114
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00384141000902'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '2iJk800hNiXDcg==',
  senhaIv = 'UO6V0DjWDDYcDRXw',
  senhaTag = 'MQ0P0PRrJjYhqpv0S98FZg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 114 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00384141000902',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00384141000902', NULL, '-----',
  '2iJk800hNiXDcg==', 'UO6V0DjWDDYcDRXw', 'MQ0P0PRrJjYhqpv0S98FZg==', 'Origem: planilha de senhas de oficinas, linha 114 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 00384141000902', 1
WHERE @portalCredentialId IS NULL;

-- Linha 115
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00384141000155'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'fo1aLDxlG5rAjz8M',
  senhaIv = 'MZbW4E48ncPQHvwK',
  senhaTag = 'gtjmA0We25//OOPkyAgGUw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 115 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00384141000155', NULL, '-----',
  'fo1aLDxlG5rAjz8M', 'MZbW4E48ncPQHvwK', 'gtjmA0We25//OOPkyAgGUw==', 'Origem: planilha de senhas de oficinas, linha 115 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155', 1
WHERE @portalCredentialId IS NULL;

-- Linha 116
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '43197396000111'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'wPPTDcjbtGqplfpg',
  senhaIv = 'PrgJgGHfqbOflagi',
  senhaTag = 'WMpEOjA8C8kg+0dfclOjWg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 116 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '43197396000111', NULL, '-----',
  'wPPTDcjbtGqplfpg', 'PrgJgGHfqbOflagi', 'WMpEOjA8C8kg+0dfclOjWg==', 'Origem: planilha de senhas de oficinas, linha 116 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111', 1
WHERE @portalCredentialId IS NULL;

-- Linha 117
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '06JKkhWccc/Okg==',
  senhaIv = 'NsZlSsd43NmbfV2x',
  senhaTag = 'BpdK65J3r+/OrzREUtuILQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 117 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002197', NULL, '-----',
  '06JKkhWccc/Okg==', 'NsZlSsd43NmbfV2x', 'BpdK65J3r+/OrzREUtuILQ==', 'Origem: planilha de senhas de oficinas, linha 117 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 118
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002359'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WYfNhLQo6UOhBMFF',
  senhaIv = 'iQRizLmb6AIYRBJq',
  senhaTag = 'BHgXYXLPdRsdSeyIPrYvGQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 118 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002359', NULL, '-----',
  'WYfNhLQo6UOhBMFF', 'iQRizLmb6AIYRBJq', 'BHgXYXLPdRsdSeyIPrYvGQ==', 'Origem: planilha de senhas de oficinas, linha 118 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359', 1
WHERE @portalCredentialId IS NULL;

-- Linha 119
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001891'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'k9iX5Z/DiX5+3SJeuIiB',
  senhaIv = 'zd+eK7a1zv3lS4b2',
  senhaTag = 'HDJrkZHLJYqi3F/740zzzQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 119 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001891', NULL, '-----',
  'k9iX5Z/DiX5+3SJeuIiB', 'zd+eK7a1zv3lS4b2', 'HDJrkZHLJYqi3F/740zzzQ==', 'Origem: planilha de senhas de oficinas, linha 119 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891', 1
WHERE @portalCredentialId IS NULL;

-- Linha 120
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'U1TMIYM8gBRj2g==',
  senhaIv = 'hABxurxp7F9B6opR',
  senhaTag = 'rAU3RQNA5CAWqg5hsjqYBQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 120 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'U1TMIYM8gBRj2g==', 'hABxurxp7F9B6opR', 'rAU3RQNA5CAWqg5hsjqYBQ==', 'Origem: planilha de senhas de oficinas, linha 120 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 121
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000421'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zbq6WlWSujT6',
  senhaIv = 'JB9DUUhA8FE5W6Mr',
  senhaTag = 'U1zRcQLQag3LDh4jhoW7zw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 121 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000421', NULL, '-----',
  'zbq6WlWSujT6', 'JB9DUUhA8FE5W6Mr', 'U1zRcQLQag3LDh4jhoW7zw==', 'Origem: planilha de senhas de oficinas, linha 121 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421', 1
WHERE @portalCredentialId IS NULL;

-- Linha 122
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000693'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'V3pJxs45ZoNH3Uk=',
  senhaIv = 'x+AxnSyovhlZmDYa',
  senhaTag = '8oRTikz6k0xLIQYfWY+dTg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 122 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000693', NULL, '-----',
  'V3pJxs45ZoNH3Uk=', 'x+AxnSyovhlZmDYa', '8oRTikz6k0xLIQYfWY+dTg==', 'Origem: planilha de senhas de oficinas, linha 122 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693', 1
WHERE @portalCredentialId IS NULL;

-- Linha 123
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000340'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'jscD5dEPw6DemFPm',
  senhaIv = '5RDyhfX5MRXGj10t',
  senhaTag = 'BYY10Q5JlDTsVB44SX9K/w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 123 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000340', NULL, '-----',
  'jscD5dEPw6DemFPm', '5RDyhfX5MRXGj10t', 'BYY10Q5JlDTsVB44SX9K/w==', 'Origem: planilha de senhas de oficinas, linha 123 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340', 1
WHERE @portalCredentialId IS NULL;

-- Linha 124
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000260'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'oucGCoHsRgYgv2E=',
  senhaIv = '0swnIAGIMzuof2OO',
  senhaTag = 'cHwdQI06Se/MZ6Amoo3lMw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 124 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000260', NULL, '-----',
  'oucGCoHsRgYgv2E=', '0swnIAGIMzuof2OO', 'cHwdQI06Se/MZ6Amoo3lMw==', 'Origem: planilha de senhas de oficinas, linha 124 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260', 1
WHERE @portalCredentialId IS NULL;

-- Linha 125
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WRieMOl2nxjCGsRD',
  senhaIv = 'boNZYFkDv2DwO303',
  senhaTag = '7OnbcocoYaRpfDAJ/J87Kw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 125 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'WRieMOl2nxjCGsRD', 'boNZYFkDv2DwO303', '7OnbcocoYaRpfDAJ/J87Kw==', 'Origem: planilha de senhas de oficinas, linha 125 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 126
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000774'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'xoIq6JsLyILgKqw=',
  senhaIv = 'wnSLYTjITvuDE5ol',
  senhaTag = 'h8jKGhv6G93TvbgxobuNvg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 126 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: 15917899000774',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000774', NULL, '-----',
  'xoIq6JsLyILgKqw=', 'wnSLYTjITvuDE5ol', 'h8jKGhv6G93TvbgxobuNvg==', 'Origem: planilha de senhas de oficinas, linha 126 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: 15917899000774', 1
WHERE @portalCredentialId IS NULL;

-- Linha 127
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000225'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '19mTvZ9xpl23BQ==',
  senhaIv = '52QeBpoeXpAz1+Qo',
  senhaTag = 'KfeKFJXbAJUaW9d32p60Gg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 127 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000225', NULL, '-----',
  '19mTvZ9xpl23BQ==', '52QeBpoeXpAz1+Qo', 'KfeKFJXbAJUaW9d32p60Gg==', 'Origem: planilha de senhas de oficinas, linha 127 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225', 1
WHERE @portalCredentialId IS NULL;

-- Linha 128
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000144'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'BXp39QrIcmxq',
  senhaIv = '2NzffFEzq8u+WPZn',
  senhaTag = 'VgO4/uGlw6WbgCGVyojyaw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 128 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000144', NULL, '-----',
  'BXp39QrIcmxq', '2NzffFEzq8u+WPZn', 'VgO4/uGlw6WbgCGVyojyaw==', 'Origem: planilha de senhas de oficinas, linha 128 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144', 1
WHERE @portalCredentialId IS NULL;

-- Linha 129
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000477'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Y4wDpbtHQJo=',
  senhaIv = '4pX3CPNuOwlFY4ae',
  senhaTag = 'RPor3/WGw0ir1CfbxP9B8w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 129 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000477', NULL, '-----',
  'Y4wDpbtHQJo=', '4pX3CPNuOwlFY4ae', 'RPor3/WGw0ir1CfbxP9B8w==', 'Origem: planilha de senhas de oficinas, linha 129 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477', 1
WHERE @portalCredentialId IS NULL;

-- Linha 130
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000124'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'NFP3ju3+hG4z',
  senhaIv = 'JKZhZ9pNyH4PwhlM',
  senhaTag = '464IrOVuXA4LoDOQAjXavg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 130 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000124', NULL, '-----',
  'NFP3ju3+hG4z', 'JKZhZ9pNyH4PwhlM', '464IrOVuXA4LoDOQAjXavg==', 'Origem: planilha de senhas de oficinas, linha 130 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124', 1
WHERE @portalCredentialId IS NULL;

-- Linha 131
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000140'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'bLTCf5pVwOzq',
  senhaIv = 'I7KD5X49r5UtL3QK',
  senhaTag = 'mh1yIzEbHiSNyrGsMLuTSA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 131 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000140', NULL, '-----',
  'bLTCf5pVwOzq', 'I7KD5X49r5UtL3QK', 'mh1yIzEbHiSNyrGsMLuTSA==', 'Origem: planilha de senhas de oficinas, linha 131 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140', 1
WHERE @portalCredentialId IS NULL;

-- Linha 132
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000736'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'OqnPlYvlW2gN',
  senhaIv = '9SS4sUTOyYD4DpGb',
  senhaTag = 'Xba/sWMuTIITf9gFIu4gAg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 132 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000736', NULL, '-----',
  'OqnPlYvlW2gN', '9SS4sUTOyYD4DpGb', 'Xba/sWMuTIITf9gFIu4gAg==', 'Origem: planilha de senhas de oficinas, linha 132 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736', 1
WHERE @portalCredentialId IS NULL;

-- Linha 133
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000169'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'NosEwodBGlFJ',
  senhaIv = 'q8/6WGK/9rhLvv7e',
  senhaTag = 'matbO8QwOQza0d0YopCvzg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 133 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000169', NULL, '-----',
  'NosEwodBGlFJ', 'q8/6WGK/9rhLvv7e', 'matbO8QwOQza0d0YopCvzg==', 'Origem: planilha de senhas de oficinas, linha 133 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169', 1
WHERE @portalCredentialId IS NULL;

-- Linha 134
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('HDI'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('HDI'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000240'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Vpkq915ET4CLFzQ=',
  senhaIv = 'i72fnjt/ndfJprCz',
  senhaTag = 's8A+MwV0SAnSliUZaPh7Eg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 134 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000240', NULL, '-----',
  'Vpkq915ET4CLFzQ=', 'i72fnjt/ndfJprCz', 's8A+MwV0SAnSliUZaPh7Eg==', 'Origem: planilha de senhas de oficinas, linha 134 | Segmento: OFICINA | Seguradora: HDI (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240', 1
WHERE @portalCredentialId IS NULL;

-- Linha 135
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '908020'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'FZ/4L0g/',
  senhaIv = '2AFKD8OZmSa6KUfQ',
  senhaTag = 'jI9pkiblRpRai1xZ06RHJA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 135 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 908020',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '908020', NULL, '-----',
  'FZ/4L0g/', '2AFKD8OZmSa6KUfQ', 'jI9pkiblRpRai1xZ06RHJA==', 'Origem: planilha de senhas de oficinas, linha 135 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 908020', 1
WHERE @portalCredentialId IS NULL;

-- Linha 136
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '913376'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'g2tMdnc0E8aE+opuwA==',
  senhaIv = '+tDyZ0n72VwWwtbN',
  senhaTag = 'PBIYDf6GA5fwwX8FsBPdQA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 136 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 913376',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '913376', NULL, '-----',
  'g2tMdnc0E8aE+opuwA==', '+tDyZ0n72VwWwtbN', 'PBIYDf6GA5fwwX8FsBPdQA==', 'Origem: planilha de senhas de oficinas, linha 136 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 913376', 1
WHERE @portalCredentialId IS NULL;

-- Linha 137
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '908821'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'I4IepEo1',
  senhaIv = 'B9cCLxqoBkZPpCX3',
  senhaTag = 'uXe1T9Kt9hGX89WDiOEw7g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 137 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 908821',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '908821', NULL, '-----',
  'I4IepEo1', 'B9cCLxqoBkZPpCX3', 'uXe1T9Kt9hGX89WDiOEw7g==', 'Origem: planilha de senhas de oficinas, linha 137 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 908821', 1
WHERE @portalCredentialId IS NULL;

-- Linha 138
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '903682'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'yFLsWFQ6',
  senhaIv = 'dKnuJe+45l9rSY+f',
  senhaTag = 'E78ZapNicqBhKYE4KyaHFg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 138 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 903682',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '903682', NULL, '-----',
  'yFLsWFQ6', 'dKnuJe+45l9rSY+f', 'E78ZapNicqBhKYE4KyaHFg==', 'Origem: planilha de senhas de oficinas, linha 138 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 903682', 1
WHERE @portalCredentialId IS NULL;

-- Linha 139
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '903960'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'LUHrmnaR',
  senhaIv = 'kNADkWtxjDV5knLM',
  senhaTag = 'WDlIUOrEnck99PItLaftrw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 139 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 903960',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '903960', NULL, '-----',
  'LUHrmnaR', 'kNADkWtxjDV5knLM', 'WDlIUOrEnck99PItLaftrw==', 'Origem: planilha de senhas de oficinas, linha 139 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 903960', 1
WHERE @portalCredentialId IS NULL;

-- Linha 140
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '905123'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zRPg0iWp',
  senhaIv = 'zEHRl6aBgw3/9e6F',
  senhaTag = 'hsUDtxlddUivmdRG5V9eGA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 140 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 905123',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '905123', NULL, '-----',
  'zRPg0iWp', 'zEHRl6aBgw3/9e6F', 'hsUDtxlddUivmdRG5V9eGA==', 'Origem: planilha de senhas de oficinas, linha 140 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 905123', 1
WHERE @portalCredentialId IS NULL;

-- Linha 141
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Mapfre'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Mapfre'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '880880'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ZQEsCxyL',
  senhaIv = 'jJo4o0bG3G1lXCUV',
  senhaTag = 'yxrA4dG7O6VyWGPtsoO22g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 141 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP São Carlos | CNPJ: 46.101.424/0025-10 | Acesso original: 880880',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '880880', NULL, '-----',
  'ZQEsCxyL', 'jJo4o0bG3G1lXCUV', 'yxrA4dG7O6VyWGPtsoO22g==', 'Origem: planilha de senhas de oficinas, linha 141 | Segmento: ALL RISK | Seguradora: MAPFRE (AR Atri e Jeep) | Empresa: JEEP São Carlos | CNPJ: 46.101.424/0025-10 | Acesso original: 880880', 1
WHERE @portalCredentialId IS NULL;

-- Linha 143
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'IUgQC/J6rJQ=',
  senhaIv = '62WrroYV2YKePFzD',
  senhaTag = 'xz9hiVzZW5aRG/usARyw/g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 143 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'IUgQC/J6rJQ=', '62WrroYV2YKePFzD', 'xz9hiVzZW5aRG/usARyw/g==', 'Origem: planilha de senhas de oficinas, linha 143 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 144
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'QAFu/SD459c=',
  senhaIv = 'yTxrqEPN+BZ3vweh',
  senhaTag = '4VDZl+LiQaLAZWzltycUDg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 144 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'QAFu/SD459c=', 'yTxrqEPN+BZ3vweh', '4VDZl+LiQaLAZWzltycUDg==', 'Origem: planilha de senhas de oficinas, linha 144 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 145
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'bdXAslZwW7w=',
  senhaIv = 'v7e0Yj1W2HZLQL3W',
  senhaTag = 'w85gAF60Mt8VRJ/BtLs3MA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 145 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'bdXAslZwW7w=', 'v7e0Yj1W2HZLQL3W', 'w85gAF60Mt8VRJ/BtLs3MA==', 'Origem: planilha de senhas de oficinas, linha 145 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 146
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Rrzv9gyZWwE=',
  senhaIv = 'ZvFEptaCMhFVO+Rf',
  senhaTag = 'RKWHtop1EmN+RYPWK92VFg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 146 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'Rrzv9gyZWwE=', 'ZvFEptaCMhFVO+Rf', 'RKWHtop1EmN+RYPWK92VFg==', 'Origem: planilha de senhas de oficinas, linha 146 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 147
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'FI5mT8/xl8Q=',
  senhaIv = 'f5XXj6/IUe9ond2W',
  senhaTag = 'iifVsw8hKYDE8QK6NqZNrA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 147 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'FI5mT8/xl8Q=', 'f5XXj6/IUe9ond2W', 'iifVsw8hKYDE8QK6NqZNrA==', 'Origem: planilha de senhas de oficinas, linha 147 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 148
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'STryfRsIgcs=',
  senhaIv = 'FwwlJOxV/03uxagr',
  senhaTag = '6Zvt/dcydsLF0wS+pdKMXA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 148 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'STryfRsIgcs=', 'FwwlJOxV/03uxagr', '6Zvt/dcydsLF0wS+pdKMXA==', 'Origem: planilha de senhas de oficinas, linha 148 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 149
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '34622129825'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '6fsSpms=',
  senhaIv = 'rjSml/Hrxrn5prs3',
  senhaTag = '0vHlPzqXcY0VVTBQK8VYcg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 149 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 34622129825',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '34622129825', NULL, '-----',
  '6fsSpms=', 'rjSml/Hrxrn5prs3', '0vHlPzqXcY0VVTBQK8VYcg==', 'Origem: planilha de senhas de oficinas, linha 149 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 34622129825', 1
WHERE @portalCredentialId IS NULL;

-- Linha 150
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sLYUELqpVAM=',
  senhaIv = '9VY0324LnxygMHZn',
  senhaTag = '1hXIpp4qROgTkr1V5xrPlA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 150 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'sLYUELqpVAM=', '9VY0324LnxygMHZn', '1hXIpp4qROgTkr1V5xrPlA==', 'Origem: planilha de senhas de oficinas, linha 150 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 151
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '26941480858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zBskiJXNzDI=',
  senhaIv = '1Vb9P7odS4uulb7Q',
  senhaTag = '20wO0WE+wjg4XMTqSyY8gw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 151 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 26941480858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '26941480858', NULL, '-----',
  'zBskiJXNzDI=', '1Vb9P7odS4uulb7Q', '20wO0WE+wjg4XMTqSyY8gw==', 'Origem: planilha de senhas de oficinas, linha 151 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 26941480858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 152
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '26941480858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'VWGvqyh0gJc=',
  senhaIv = 'LMgYAVi4HCfdMpxY',
  senhaTag = '5/AFfbLDp5YWVcWtzyK5iw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 152 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 26941480858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '26941480858', NULL, '-----',
  'VWGvqyh0gJc=', 'LMgYAVi4HCfdMpxY', '5/AFfbLDp5YWVcWtzyK5iw==', 'Origem: planilha de senhas de oficinas, linha 152 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 26941480858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 153
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Qi++cDU4/xE=',
  senhaIv = 'TfM1cH67EytBiyRb',
  senhaTag = 'RtvW889bvJx9RJpxNjGDsw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 153 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'Qi++cDU4/xE=', 'TfM1cH67EytBiyRb', 'RtvW889bvJx9RJpxNjGDsw==', 'Origem: planilha de senhas de oficinas, linha 153 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 154
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WIqZS5TFcmw=',
  senhaIv = 'bUz8VPCgsHGKh/M2',
  senhaTag = '9/6JCdNcuEZ18z1fFcQ3SA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 154 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'WIqZS5TFcmw=', 'bUz8VPCgsHGKh/M2', '9/6JCdNcuEZ18z1fFcQ3SA==', 'Origem: planilha de senhas de oficinas, linha 154 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 155
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '34042723873'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '5tDcdE0=',
  senhaIv = 'rf6i8cU4b9iRrUq3',
  senhaTag = 'GGWk3HviVFmw3wHY96u+rA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 155 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 34042723873',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '34042723873', NULL, '-----',
  '5tDcdE0=', 'rf6i8cU4b9iRrUq3', 'GGWk3HviVFmw3wHY96u+rA==', 'Origem: planilha de senhas de oficinas, linha 155 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 34042723873', 1
WHERE @portalCredentialId IS NULL;

-- Linha 156
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '26941480858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'CAyB4//fgig=',
  senhaIv = 'fotbhT+41xUWQK3E',
  senhaTag = 'oaqO6fUbAxhb8sBCnFA2+w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 156 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 26941480858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '26941480858', NULL, '-----',
  'CAyB4//fgig=', 'fotbhT+41xUWQK3E', 'oaqO6fUbAxhb8sBCnFA2+w==', 'Origem: planilha de senhas de oficinas, linha 156 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 26941480858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 157
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08872127866'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'jVuie14=',
  senhaIv = 'TixcdegLQboJVFUe',
  senhaTag = 'OaKTliyFXZI4+bcxlSSAYw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 157 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 08872127866',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08872127866', NULL, '-----',
  'jVuie14=', 'TixcdegLQboJVFUe', 'OaKTliyFXZI4+bcxlSSAYw==', 'Origem: planilha de senhas de oficinas, linha 157 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 08872127866', 1
WHERE @portalCredentialId IS NULL;

-- Linha 158
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '34622129825'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'v4lcNfI=',
  senhaIv = '9FaLggyonfecmYkK',
  senhaTag = 'Lg8r4i1zYmUND+TSuDawhQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 158 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 34622129825',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '34622129825', NULL, '-----',
  'v4lcNfI=', '9FaLggyonfecmYkK', 'Lg8r4i1zYmUND+TSuDawhQ==', 'Origem: planilha de senhas de oficinas, linha 158 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 34622129825', 1
WHERE @portalCredentialId IS NULL;

-- Linha 159
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'qbxsd0LTNkE=',
  senhaIv = 'qL/LyyZQgeJZXXsV',
  senhaTag = 'PvXQRdxin1JY3ISamreu/A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 159 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'qbxsd0LTNkE=', 'qL/LyyZQgeJZXXsV', 'PvXQRdxin1JY3ISamreu/A==', 'Origem: planilha de senhas de oficinas, linha 159 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 160
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '34622129825'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'czg4fDY=',
  senhaIv = 'RDbmzkvatLlB7+XS',
  senhaTag = 'W0ah3wijcGtCSYLbWvW8Sg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 160 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 34622129825',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '34622129825', NULL, '-----',
  'czg4fDY=', 'RDbmzkvatLlB7+XS', 'W0ah3wijcGtCSYLbWvW8Sg==', 'Origem: planilha de senhas de oficinas, linha 160 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 34622129825', 1
WHERE @portalCredentialId IS NULL;

-- Linha 161
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'w2s7myzuPYM=',
  senhaIv = 'LbsT4HIAyW4ZMjjh',
  senhaTag = '0BhGrzv7oUzllSJkBNPy1Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 161 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'w2s7myzuPYM=', 'LbsT4HIAyW4ZMjjh', '0BhGrzv7oUzllSJkBNPy1Q==', 'Origem: planilha de senhas de oficinas, linha 161 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 162
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '39191434858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'hnNfTbHJVP4=',
  senhaIv = '/Oz5sxuugMoDpGlB',
  senhaTag = 'vDGH4LZQ35vCCbEn8V+6Bg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 162 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 39191434858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '39191434858', NULL, '-----',
  'hnNfTbHJVP4=', '/Oz5sxuugMoDpGlB', 'vDGH4LZQ35vCCbEn8V+6Bg==', 'Origem: planilha de senhas de oficinas, linha 162 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 39191434858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 163
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '28329382800'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '19b+LQw=',
  senhaIv = 'XWjHCPVhOmn72b/l',
  senhaTag = '0zhwQCrOd0v+2pnDd1tcRA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 163 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 28329382800',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '28329382800', NULL, '-----',
  '19b+LQw=', 'XWjHCPVhOmn72b/l', '0zhwQCrOd0v+2pnDd1tcRA==', 'Origem: planilha de senhas de oficinas, linha 163 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Lexus | CNPJ: 24.896.001/0003-96 | Acesso original: 28329382800', 1
WHERE @portalCredentialId IS NULL;

-- Linha 164
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'bBuYaDqc7H4=',
  senhaIv = 'E1GKHr9OBRP7bZhZ',
  senhaTag = 'WGKGRZpTUGSoaN7tkWt9aw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 164 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  'bBuYaDqc7H4=', 'E1GKHr9OBRP7bZhZ', 'WGKGRZpTUGSoaN7tkWt9aw==', 'Origem: planilha de senhas de oficinas, linha 164 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 165
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '42544252871'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sW7yuurGV8A=',
  senhaIv = 'JuAAGJShPYqwMT7D',
  senhaTag = 'dptC2S/HZIX9xYfsVBcTNg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 165 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 42544252871',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '42544252871', NULL, '-----',
  'sW7yuurGV8A=', 'JuAAGJShPYqwMT7D', 'dptC2S/HZIX9xYfsVBcTNg==', 'Origem: planilha de senhas de oficinas, linha 165 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 42544252871', 1
WHERE @portalCredentialId IS NULL;

-- Linha 166
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08872127866'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '01TypSQ=',
  senhaIv = 'p8WmU2foATByvWFq',
  senhaTag = 'XdANo6/NwPBHndqi4y3WNw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 166 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 08872127866',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08872127866', NULL, '-----',
  '01TypSQ=', 'p8WmU2foATByvWFq', 'XdANo6/NwPBHndqi4y3WNw==', 'Origem: planilha de senhas de oficinas, linha 166 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 08872127866', 1
WHERE @portalCredentialId IS NULL;

-- Linha 167
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '30776532812'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'n836xAU=',
  senhaIv = 'Pf81nyWmeqeuxNuE',
  senhaTag = 'TELP14oA3uMR51bH/MshUg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 167 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 30776532812',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '30776532812', NULL, '-----',
  'n836xAU=', 'Pf81nyWmeqeuxNuE', 'TELP14oA3uMR51bH/MshUg==', 'Origem: planilha de senhas de oficinas, linha 167 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 30776532812', 1
WHERE @portalCredentialId IS NULL;

-- Linha 168
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '17829067899'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '+pifpcCbzfU=',
  senhaIv = 'Yd/Bj3ZChUF5cD9f',
  senhaTag = 'ytbNBSN/9pVUTxGcjeFj4Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 168 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 17829067899',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '17829067899', NULL, '-----',
  '+pifpcCbzfU=', 'Yd/Bj3ZChUF5cD9f', 'ytbNBSN/9pVUTxGcjeFj4Q==', 'Origem: planilha de senhas de oficinas, linha 168 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 17829067899', 1
WHERE @portalCredentialId IS NULL;

-- Linha 169
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '40562632808'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '0fRQJqA=',
  senhaIv = 'lXg4y2iiL6A5zYEc',
  senhaTag = 'w4F/HQV1kK2xVtdoNwFX0g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 169 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 40562632808',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '40562632808', NULL, '-----',
  '0fRQJqA=', 'lXg4y2iiL6A5zYEc', 'w4F/HQV1kK2xVtdoNwFX0g==', 'Origem: planilha de senhas de oficinas, linha 169 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 40562632808', 1
WHERE @portalCredentialId IS NULL;

-- Linha 170
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Porto'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Porto'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '26941480858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'UC8HdNG5i+Y=',
  senhaIv = 'IObYlSOM6vRNRflg',
  senhaTag = '2KQXJggpfkLLkH1OJuHNog==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 170 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 26941480858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '26941480858', NULL, '-----',
  'UC8HdNG5i+Y=', 'IObYlSOM6vRNRflg', '2KQXJggpfkLLkH1OJuHNog==', 'Origem: planilha de senhas de oficinas, linha 170 | Segmento: OFICINA | Seguradora: PORTO SEGURO (OFC) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 26941480858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 171
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atriaraçatuba'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'JQuXKU6H1Po=',
  senhaIv = 'hDgaR+gwU+wISjFG',
  senhaTag = 'fTd9Tanq3S0ABkDrUvCEgg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 171 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: luciana.atriaraçatuba',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atriaraçatuba', NULL, '-----',
  'JQuXKU6H1Po=', 'hDgaR+gwU+wISjFG', 'fTd9Tanq3S0ABkDrUvCEgg==', 'Origem: planilha de senhas de oficinas, linha 171 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Araçatuba | CNPJ: 46.101.424/0014-68 | Acesso original: luciana.atriaraçatuba', 1
WHERE @portalCredentialId IS NULL;

-- Linha 172
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atriararaquara'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atriararaquara',
  senhaCriptografada = '+kkJSaXMXQc=',
  senhaIv = 'G5aUzyJ3ffbCNiWm',
  senhaTag = '6X7Z8iHA4ootnEZGgWiJTA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 172 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: luciana.atriararaquara',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atriararaquara', 'luciana.atriararaquara', '-----',
  '+kkJSaXMXQc=', 'G5aUzyJ3ffbCNiWm', '6X7Z8iHA4ootnEZGgWiJTA==', 'Origem: planilha de senhas de oficinas, linha 172 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: luciana.atriararaquara', 1
WHERE @portalCredentialId IS NULL;

-- Linha 173
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atrirp'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atrirp',
  senhaCriptografada = 'M29+x+nDLQQ=',
  senhaIv = 'v8NJxAX7OoOabpHr',
  senhaTag = 'b4XykJlVj4UAywqRukxJhQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 173 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: luciana.atrirp',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atrirp', 'luciana.atrirp', '-----',
  'M29+x+nDLQQ=', 'v8NJxAX7OoOabpHr', 'b4XykJlVj4UAywqRukxJhQ==', 'Origem: planilha de senhas de oficinas, linha 173 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: luciana.atrirp', 1
WHERE @portalCredentialId IS NULL;

-- Linha 174
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atrisantos'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atrisantos',
  senhaCriptografada = 'jFEgrQ17lao=',
  senhaIv = 'KAhvHtfiugLeX+DZ',
  senhaTag = '2OLb374OwfPCtYvZCe7y4w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 174 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: luciana.atrisantos',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atrisantos', 'luciana.atrisantos', '-----',
  'jFEgrQ17lao=', 'KAhvHtfiugLeX+DZ', '2OLb374OwfPCtYvZCe7y4w==', 'Origem: planilha de senhas de oficinas, linha 174 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: luciana.atrisantos', 1
WHERE @portalCredentialId IS NULL;

-- Linha 175
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atriaudi'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atriaudi',
  senhaCriptografada = 'OU3OhPQ0zbQ=',
  senhaIv = 'mLFtFyihK5vTUAv7',
  senhaTag = '/mthlAei+DhLqDBcj1Otrw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 175 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: luciana.atriaudi',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atriaudi', 'luciana.atriaudi', '-----',
  'OU3OhPQ0zbQ=', 'mLFtFyihK5vTUAv7', '/mthlAei+DhLqDBcj1Otrw==', 'Origem: planilha de senhas de oficinas, linha 175 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: luciana.atriaudi', 1
WHERE @portalCredentialId IS NULL;

-- Linha 176
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atri'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atri',
  senhaCriptografada = 'Yn5iiwACDbg=',
  senhaIv = 'vweWl2mY4onBb7lV',
  senhaTag = '7dkYnEc9VcSC9KpFSgV5Tg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 176 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: luciana.atri',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atri', 'luciana.atri', '-----',
  'Yn5iiwACDbg=', 'vweWl2mY4onBb7lV', '7dkYnEc9VcSC9KpFSgV5Tg==', 'Origem: planilha de senhas de oficinas, linha 176 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: luciana.atri', 1
WHERE @portalCredentialId IS NULL;

-- Linha 177
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.euro'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.euro',
  senhaCriptografada = 'WpHUICuJblE=',
  senhaIv = 'WYWgdy1H2Purja2w',
  senhaTag = 'w977cmwJF9qfKUVVI7+U5g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 177 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: luciana.euro',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.euro', 'luciana.euro', '-----',
  'WpHUICuJblE=', 'WYWgdy1H2Purja2w', 'w977cmwJF9qfKUVVI7+U5g==', 'Origem: planilha de senhas de oficinas, linha 177 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: luciana.euro', 1
WHERE @portalCredentialId IS NULL;

-- Linha 178
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.atrijeep'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.atrijeep',
  senhaCriptografada = '1ljPmMp9zP0=',
  senhaIv = 'sDBAhN0dpYcIx0PT',
  senhaTag = 'PZYGFR0ksz1Ou1PrPgZXlg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 178 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: luciana.atrijeep',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.atrijeep', 'luciana.atrijeep', '-----',
  '1ljPmMp9zP0=', 'sDBAhN0dpYcIx0PT', 'PZYGFR0ksz1Ou1PrPgZXlg==', 'Origem: planilha de senhas de oficinas, linha 178 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: luciana.atrijeep', 1
WHERE @portalCredentialId IS NULL;

-- Linha 179
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.koi'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.koi',
  senhaCriptografada = 'Ib+nOeLe4t4=',
  senhaIv = 'ABz9IME2cbTBV/vk',
  senhaTag = 'mDp7pWDEafkaJ2k1p0i/yQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 179 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: luciana.koi',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.koi', 'luciana.koi', '-----',
  'Ib+nOeLe4t4=', 'ABz9IME2cbTBV/vk', 'mDp7pWDEafkaJ2k1p0i/yQ==', 'Origem: planilha de senhas de oficinas, linha 179 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: luciana.koi', 1
WHERE @portalCredentialId IS NULL;

-- Linha 180
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.newar'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.newar',
  senhaCriptografada = 'k87KdRmq18I=',
  senhaIv = 'Lca0PFP5q91ElI4m',
  senhaTag = 'omY5OGGRcnY5z/uS7yHliQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 180 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: luciana.newar',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.newar', 'luciana.newar', '-----',
  'k87KdRmq18I=', 'Lca0PFP5q91ElI4m', 'omY5OGGRcnY5z/uS7yHliQ==', 'Origem: planilha de senhas de oficinas, linha 180 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: luciana.newar', 1
WHERE @portalCredentialId IS NULL;

-- Linha 181
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.newhyundai'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.newhyundai',
  senhaCriptografada = 'yyyecniMGMo=',
  senhaIv = 'trVRcX9ExfkF91K0',
  senhaTag = 'MckHLfcURUtmFeGoFBbHIQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 181 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: luciana.newhyundai',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.newhyundai', 'luciana.newhyundai', '-----',
  'yyyecniMGMo=', 'trVRcX9ExfkF91K0', 'MckHLfcURUtmFeGoFBbHIQ==', 'Origem: planilha de senhas de oficinas, linha 181 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: luciana.newhyundai', 1
WHERE @portalCredentialId IS NULL;

-- Linha 182
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.new'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.new',
  senhaCriptografada = 'oKeAs0WLkg==',
  senhaIv = 'arTzuOTdNiAPK7jY',
  senhaTag = 'GQjYVJotp/tLy9jicZBOUA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 182 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: luciana.new',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.new', 'luciana.new', '-----',
  'oKeAs0WLkg==', 'arTzuOTdNiAPK7jY', 'GQjYVJotp/tLy9jicZBOUA==', 'Origem: planilha de senhas de oficinas, linha 182 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: luciana.new', 1
WHERE @portalCredentialId IS NULL;

-- Linha 183
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.keiji'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.keiji',
  senhaCriptografada = '005kpbmWu44=',
  senhaIv = '+X7jrJP2qMzZaD3L',
  senhaTag = '4k+NkKvLPbpSlFdAveuePw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 183 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: luciana.keiji',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.keiji', 'luciana.keiji', '-----',
  '005kpbmWu44=', '+X7jrJP2qMzZaD3L', '4k+NkKvLPbpSlFdAveuePw==', 'Origem: planilha de senhas de oficinas, linha 183 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: luciana.keiji', 1
WHERE @portalCredentialId IS NULL;

-- Linha 184
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.ontake'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.ontake',
  senhaCriptografada = '9MpKvmFYXR8=',
  senhaIv = 'jqlLUSGTmlA2w+DX',
  senhaTag = 'boNp20R6Ls4J2/kNiG5vBg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 184 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: luciana.ontake',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.ontake', 'luciana.ontake', '-----',
  '9MpKvmFYXR8=', 'jqlLUSGTmlA2w+DX', 'boNp20R6Ls4J2/kNiG5vBg==', 'Origem: planilha de senhas de oficinas, linha 184 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: luciana.ontake', 1
WHERE @portalCredentialId IS NULL;

-- Linha 185
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.ortovelrp'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.ortovelrp',
  senhaCriptografada = 'Sgr+nDP7iVc=',
  senhaIv = 'U+LcaU5RIeD2BHvO',
  senhaTag = 'hfoOZes3IFS2Lq/Ewvq6EQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 185 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: luciana.ortovelrp',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.ortovelrp', 'luciana.ortovelrp', '-----',
  'Sgr+nDP7iVc=', 'U+LcaU5RIeD2BHvO', 'hfoOZes3IFS2Lq/Ewvq6EQ==', 'Origem: planilha de senhas de oficinas, linha 185 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: luciana.ortovelrp', 1
WHERE @portalCredentialId IS NULL;

-- Linha 186
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.ortovel'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.ortovel',
  senhaCriptografada = 'mpExkiAYtRE=',
  senhaIv = 'LOG2hPlmUbM0q+CB',
  senhaTag = 'Cfz2+ojFP5UeO/+ApPVohg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 186 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: luciana.ortovel',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.ortovel', 'luciana.ortovel', '-----',
  'mpExkiAYtRE=', 'LOG2hPlmUbM0q+CB', 'Cfz2+ojFP5UeO/+ApPVohg==', 'Origem: planilha de senhas de oficinas, linha 186 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: luciana.ortovel', 1
WHERE @portalCredentialId IS NULL;

-- Linha 187
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('PRISMATEC'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('PRISMATEC'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'luciana.volvo'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'luciana.volvo',
  senhaCriptografada = 'LQKJzR1fnSA=',
  senhaIv = 'kQUwvMwFo9w6voFM',
  senhaTag = 'yXXNLYMKcfVlAEbMNnaz5A==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 187 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: luciana.volvo',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'luciana.volvo', 'luciana.volvo', '-----',
  'LQKJzR1fnSA=', 'kQUwvMwFo9w6voFM', 'yXXNLYMKcfVlAEbMNnaz5A==', 'Origem: planilha de senhas de oficinas, linha 187 | Segmento: FORNECIMENTO | Seguradora: PRISMATEC | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: luciana.volvo', 1
WHERE @portalCredentialId IS NULL;

-- Linha 189
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sompo'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sompo'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'ptrovo'
    AND usuario = 'Portal AON'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'GjyHYgjMBRA=',
  senhaIv = 'xZx9UgxRbetpkNB7',
  senhaTag = 'aFm4AKA2sSewGgCGC98RrQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 189 | Segmento: ALL RISK | Seguradora: SOMPO (AR Audi RP / AON) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: ptrovo',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'ptrovo', NULL, 'Portal AON',
  'GjyHYgjMBRA=', 'xZx9UgxRbetpkNB7', 'aFm4AKA2sSewGgCGC98RrQ==', 'Origem: planilha de senhas de oficinas, linha 189 | Segmento: ALL RISK | Seguradora: SOMPO (AR Audi RP / AON) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: ptrovo', 1
WHERE @portalCredentialId IS NULL;

-- Linha 190
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sompo'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sompo'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179 (Portal SOMPO)'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'DWSMRhuGBxKVS6g=',
  senhaIv = 'MKyvZiBQ2iJ8JNDg',
  senhaTag = 'TPAC6Z5fejeNmaYns+T9Sw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 190 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179 (Portal SOMPO)',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179 (Portal SOMPO)', NULL, '-----',
  'DWSMRhuGBxKVS6g=', 'MKyvZiBQ2iJ8JNDg', 'TPAC6Z5fejeNmaYns+T9Sw==', 'Origem: planilha de senhas de oficinas, linha 190 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179 (Portal SOMPO)', 1
WHERE @portalCredentialId IS NULL;

-- Linha 193
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sompo'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sompo'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'newd01 (Portal SOMPO)'
    AND usuario = 'Portal AON'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'O7bGxETp',
  senhaIv = 'I6TosXITR3/FyDZ/',
  senhaTag = 'Pyn1UVNXE8azjRJfMeX/Fg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 193 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: newd01 (Portal SOMPO)',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'newd01 (Portal SOMPO)', NULL, 'Portal AON',
  'O7bGxETp', 'I6TosXITR3/FyDZ/', 'Pyn1UVNXE8azjRJfMeX/Fg==', 'Origem: planilha de senhas de oficinas, linha 193 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: newd01 (Portal SOMPO)', 1
WHERE @portalCredentialId IS NULL;

-- Linha 194
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sompo'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sompo'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'newt01 (SOMPO) / 8120054 (AON)'
    AND usuario = 'Portal AON'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'fuOIMk7rYZaD3sfKj611',
  senhaIv = 'WVK3U442mgjYPoOr',
  senhaTag = 'S6WwTrgVjGivjxZPrFQQFA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 194 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: newt01 (SOMPO) / 8120054 (AON)',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'newt01 (SOMPO) / 8120054 (AON)', NULL, 'Portal AON',
  'fuOIMk7rYZaD3sfKj611', 'WVK3U442mgjYPoOr', 'S6WwTrgVjGivjxZPrFQQFA==', 'Origem: planilha de senhas de oficinas, linha 194 | Segmento: ALL RISK | Seguradora: SOMPO (AR) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: newt01 (SOMPO) / 8120054 (AON)', 1
WHERE @portalCredentialId IS NULL;

-- Linha 197
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'INATIVO'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'jud2XvBA5w==',
  senhaIv = 'DY60PYic6uNyUPJ4',
  senhaTag = 'q9V4Uw8TTPziCKqbji/WoA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 197 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: INATIVO',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'INATIVO', NULL, '-----',
  'jud2XvBA5w==', 'DY60PYic6uNyUPJ4', 'q9V4Uw8TTPziCKqbji/WoA==', 'Origem: planilha de senhas de oficinas, linha 197 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: AUDI Bauru | CNPJ: 22.220.764/0001-25 | Acesso original: INATIVO', 1
WHERE @portalCredentialId IS NULL;

-- Linha 198
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'Por e-mail'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'PsqhZ0A+VnxXrg==',
  senhaIv = 'GWk0O+FXd8xL5ttC',
  senhaTag = 't13rp6oodoDKxmbt9lPonQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 198 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: Por e-mail',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'Por e-mail', NULL, '-----',
  'PsqhZ0A+VnxXrg==', 'GWk0O+FXd8xL5ttC', 't13rp6oodoDKxmbt9lPonQ==', 'Origem: planilha de senhas de oficinas, linha 198 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: Por e-mail', 1
WHERE @portalCredentialId IS NULL;

-- Linha 199
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'FORD04701 / FORD04146'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'rI/ibRh0FnnJYDgeLlKxr5ovsg==',
  senhaIv = '/QLoX4DB86AfWB5s',
  senhaTag = 'qb6UFv4XCRf8P5q1cyENbg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 199 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: FORD04701 / FORD04146',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'FORD04701 / FORD04146', NULL, '-----',
  'rI/ibRh0FnnJYDgeLlKxr5ovsg==', '/QLoX4DB86AfWB5s', 'qb6UFv4XCRf8P5q1cyENbg==', 'Origem: planilha de senhas de oficinas, linha 199 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: FORD04701 / FORD04146', 1
WHERE @portalCredentialId IS NULL;

-- Linha 200
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'FORD04070'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'TJto2SM9umg=',
  senhaIv = 'qoWS6Ew5/AlcTSPu',
  senhaTag = 'QDwyiVqROCXGNhgbWEhrfg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 200 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: FORD04070',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'FORD04070', NULL, '-----',
  'TJto2SM9umg=', 'qoWS6Ew5/AlcTSPu', 'QDwyiVqROCXGNhgbWEhrfg==', 'Origem: planilha de senhas de oficinas, linha 200 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: FORD04070', 1
WHERE @portalCredentialId IS NULL;

-- Linha 201
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'Por e-mail'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '75WrWwxybXV8oQ==',
  senhaIv = 'TIIrp/N+w82V/eOX',
  senhaTag = 'LpbI/oDNXPt5gALziigTXA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 201 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: Por e-mail',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'Por e-mail', NULL, '-----',
  '75WrWwxybXV8oQ==', 'TIIrp/N+w82V/eOX', 'LpbI/oDNXPt5gALziigTXA==', 'Origem: planilha de senhas de oficinas, linha 201 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: Por e-mail', 1
WHERE @portalCredentialId IS NULL;

-- Linha 202
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Sura'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Sura'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'Por e-mail'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'bVMs0ELjdB6OcA==',
  senhaIv = 'lJlu4frvl0KtTW5f',
  senhaTag = 'TQZkh7NT5kzWNP4wLTpogg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 202 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: Por e-mail',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'Por e-mail', NULL, '-----',
  'bVMs0ELjdB6OcA==', 'lJlu4frvl0KtTW5f', 'TQZkh7NT5kzWNP4wLTpogg==', 'Origem: planilha de senhas de oficinas, linha 202 | Segmento: ALL RISK | Seguradora: SURA (AR Ortovel, Audi e Thor) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: Por e-mail', 1
WHERE @portalCredentialId IS NULL;

-- Linha 203
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'supervisor.eurofr@eurorenault.com.br'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'supervisor.eurofr@eurorenault.com.br',
  senhaCriptografada = 'fMSHlJlPvQg=',
  senhaIv = 'm0y1ulXnMIvNysYW',
  senhaTag = '3N8+THzc6cKPppBLyvoFiw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 203 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: supervisor.eurofr@eurorenault.com.br',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'supervisor.eurofr@eurorenault.com.br', 'supervisor.eurofr@eurorenault.com.br', '-----',
  'fMSHlJlPvQg=', 'm0y1ulXnMIvNysYW', '3N8+THzc6cKPppBLyvoFiw==', 'Origem: planilha de senhas de oficinas, linha 203 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: supervisor.eurofr@eurorenault.com.br', 1
WHERE @portalCredentialId IS NULL;

-- Linha 204
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = 'garantia.euro@eurorenault.com.br'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = 'garantia.euro@eurorenault.com.br',
  senhaCriptografada = 'ZyamKPUCNUsJ0A==',
  senhaIv = 'Ti2x8g1U2vzKUmFT',
  senhaTag = 'HC02evKS9Fz7tkZwlh1yxg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 204 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: garantia.euro@eurorenault.com.br',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, 'garantia.euro@eurorenault.com.br', 'garantia.euro@eurorenault.com.br', '-----',
  'ZyamKPUCNUsJ0A==', 'Ti2x8g1U2vzKUmFT', 'HC02evKS9Fz7tkZwlh1yxg==', 'Origem: planilha de senhas de oficinas, linha 204 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: garantia.euro@eurorenault.com.br', 1
WHERE @portalCredentialId IS NULL;

-- Linha 205
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '1088_logistica@redenissan.com.br'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = '1088_logistica@redenissan.com.br',
  senhaCriptografada = 'mE9x/ocLjhO12g==',
  senhaIv = 'vwb5fS5Plx2bMK/u',
  senhaTag = 'wsgrEn6Ff554Jg08zZ8YKg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 205 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 1088_logistica@redenissan.com.br',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '1088_logistica@redenissan.com.br', '1088_logistica@redenissan.com.br', '-----',
  'mE9x/ocLjhO12g==', 'vwb5fS5Plx2bMK/u', 'wsgrEn6Ff554Jg08zZ8YKg==', 'Origem: planilha de senhas de oficinas, linha 205 | Segmento: ALL RISK | Seguradora: TOKIO (AR Euro / Keiji) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 1088_logistica@redenissan.com.br', 1
WHERE @portalCredentialId IS NULL;

-- Linha 206
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '27596439000185'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'yQJa3Vo6ZTHSHA==',
  senhaIv = 'O1Q7MQRACVd1PhSs',
  senhaTag = 'h8hCUw+oVS13ApDHGPnqTw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 206 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '27596439000185', NULL, '-----',
  'yQJa3Vo6ZTHSHA==', 'O1Q7MQRACVd1PhSs', 'h8hCUw+oVS13ApDHGPnqTw==', 'Origem: planilha de senhas de oficinas, linha 206 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185', 1
WHERE @portalCredentialId IS NULL;

-- Linha 208
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001387'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'iGrlFgkHUquv',
  senhaIv = '6xLB+mwF0nEafNPD',
  senhaTag = 'lPCXp+WSZVSlUwNQuv/bAw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 208 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001387', NULL, '-----',
  'iGrlFgkHUquv', '6xLB+mwF0nEafNPD', 'lPCXp+WSZVSlUwNQuv/bAw==', 'Origem: planilha de senhas de oficinas, linha 208 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387', 1
WHERE @portalCredentialId IS NULL;

-- Linha 209
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424000143'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'fR+qqAYvX5jl',
  senhaIv = '3yqN+LVUHyIpAk8f',
  senhaTag = 'PwejXIzlPhCLvg4yH953Lg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 209 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424000143', NULL, '-----',
  'fR+qqAYvX5jl', '3yqN+LVUHyIpAk8f', 'PwejXIzlPhCLvg4yH953Lg==', 'Origem: planilha de senhas de oficinas, linha 209 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143', 1
WHERE @portalCredentialId IS NULL;

-- Linha 210
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001549'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'xS0mfedyMj6t',
  senhaIv = 'niSyO4v2IBl7miw9',
  senhaTag = 'kcdkYLFZKB59wzlls8/WBQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 210 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001549', NULL, '-----',
  'xS0mfedyMj6t', 'niSyO4v2IBl7miw9', 'kcdkYLFZKB59wzlls8/WBQ==', 'Origem: planilha de senhas de oficinas, linha 210 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549', 1
WHERE @portalCredentialId IS NULL;

-- Linha 213
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000206'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'HW7QlsaAWyPH06FI',
  senhaIv = 'bkC5pV0jjlJ2E9zy',
  senhaTag = 'a3HKZ5yaWEcWJg09uLc6iA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 213 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000206', NULL, '-----',
  'HW7QlsaAWyPH06FI', 'bkC5pV0jjlJ2E9zy', 'a3HKZ5yaWEcWJg09uLc6iA==', 'Origem: planilha de senhas de oficinas, linha 213 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206', 1
WHERE @portalCredentialId IS NULL;

-- Linha 214
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46420889898'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'LDbf3RAHUopE',
  senhaIv = 'miO8A0hmWHiCaflg',
  senhaTag = '/0/v14GBbU+kZKmfaU3qcA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 214 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 46420889898',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46420889898', NULL, '-----',
  'LDbf3RAHUopE', 'miO8A0hmWHiCaflg', '/0/v14GBbU+kZKmfaU3qcA==', 'Origem: planilha de senhas de oficinas, linha 214 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 46420889898', 1
WHERE @portalCredentialId IS NULL;

-- Linha 215
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '38948027824'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'i4swV8YklnzWEQ==',
  senhaIv = 'HFw+TBTPbKhTPAtP',
  senhaTag = 'kCEBn69AJoLkPWSsTx25Nw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 215 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 38948027824',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '38948027824', NULL, '-----',
  'i4swV8YklnzWEQ==', 'HFw+TBTPbKhTPAtP', 'kCEBn69AJoLkPWSsTx25Nw==', 'Origem: planilha de senhas de oficinas, linha 215 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 38948027824', 1
WHERE @portalCredentialId IS NULL;

-- Linha 217
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '43197396000111'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'KNldBA0s2b1B',
  senhaIv = '5rU6PDMEzy04YAuH',
  senhaTag = 'jzVDhSiafwEkQky/nTuFcw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 217 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '43197396000111', NULL, '-----',
  'KNldBA0s2b1B', '5rU6PDMEzy04YAuH', 'jzVDhSiafwEkQky/nTuFcw==', 'Origem: planilha de senhas de oficinas, linha 217 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111', 1
WHERE @portalCredentialId IS NULL;

-- Linha 218
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'lZXdyx1UY6ve',
  senhaIv = '2EffUZRvWtFPxDPG',
  senhaTag = 'q2JmkeATrbFMaQ2bLy8qTg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 218 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002197', NULL, '-----',
  'lZXdyx1UY6ve', '2EffUZRvWtFPxDPG', 'q2JmkeATrbFMaQ2bLy8qTg==', 'Origem: planilha de senhas de oficinas, linha 218 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 219
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002359'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Vg0Oeq3O4SNG',
  senhaIv = 'fb7ojX1wRYLfnOhD',
  senhaTag = 'MHZ22DK9GKkLkOdsLEcCJA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 219 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002359', NULL, '-----',
  'Vg0Oeq3O4SNG', 'fb7ojX1wRYLfnOhD', 'MHZ22DK9GKkLkOdsLEcCJA==', 'Origem: planilha de senhas de oficinas, linha 219 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359', 1
WHERE @portalCredentialId IS NULL;

-- Linha 221
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001891'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'x2IKutEGTSgS',
  senhaIv = 'hDC+TUu2OiGHs5yp',
  senhaTag = 'JxDwe88t3o0N2Rueyl21MA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 221 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001891', NULL, '-----',
  'x2IKutEGTSgS', 'hDC+TUu2OiGHs5yp', 'JxDwe88t3o0N2Rueyl21MA==', 'Origem: planilha de senhas de oficinas, linha 221 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891', 1
WHERE @portalCredentialId IS NULL;

-- Linha 222
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002510'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'MjzjAIiGhzE=',
  senhaIv = 'DHqZdizZ8AoiNoR6',
  senhaTag = 'iU+3pMFsab8TNwFalWwyDA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 222 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP São Carlos | CNPJ: 46.101.424/0025-10 | Acesso original: 46101424002510',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002510', NULL, '-----',
  'MjzjAIiGhzE=', 'DHqZdizZ8AoiNoR6', 'iU+3pMFsab8TNwFalWwyDA==', 'Origem: planilha de senhas de oficinas, linha 222 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: JEEP São Carlos | CNPJ: 46.101.424/0025-10 | Acesso original: 46101424002510', 1
WHERE @portalCredentialId IS NULL;

-- Linha 223
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'NBPDkkSKj6cTuw==',
  senhaIv = 'k1bnt0Yg49eIUjcV',
  senhaTag = 'NFIs6BrsxyARz6e2uy/rvA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 223 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'NBPDkkSKj6cTuw==', 'k1bnt0Yg49eIUjcV', 'NFIs6BrsxyARz6e2uy/rvA==', 'Origem: planilha de senhas de oficinas, linha 223 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 225
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000421'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'kl4+r1qbrlP9R5g=',
  senhaIv = 'ulYxzF4ls5rM2JFM',
  senhaTag = 'Caw1VHRRklATet63lxbWjA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 225 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000421', NULL, '-----',
  'kl4+r1qbrlP9R5g=', 'ulYxzF4ls5rM2JFM', 'Caw1VHRRklATet63lxbWjA==', 'Origem: planilha de senhas de oficinas, linha 225 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421', 1
WHERE @portalCredentialId IS NULL;

-- Linha 226
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '39191434858'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'dCvgjOE6iaE=',
  senhaIv = '93eneCh4qMnTGCs4',
  senhaTag = '+R+hp9c+ZV/U97vL2muz4g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 226 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 39191434858',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '39191434858', NULL, '-----',
  'dCvgjOE6iaE=', '93eneCh4qMnTGCs4', '+R+hp9c+ZV/U97vL2muz4g==', 'Origem: planilha de senhas de oficinas, linha 226 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 39191434858', 1
WHERE @portalCredentialId IS NULL;

-- Linha 227
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000340'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Sh2JPbVUOC9wgcQj',
  senhaIv = 'a0GuyR+aKMRWkanO',
  senhaTag = 'bVrSgkSqgE7jv9ivTtPIhQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 227 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000340', NULL, '-----',
  'Sh2JPbVUOC9wgcQj', 'a0GuyR+aKMRWkanO', 'bVrSgkSqgE7jv9ivTtPIhQ==', 'Origem: planilha de senhas de oficinas, linha 227 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340', 1
WHERE @portalCredentialId IS NULL;

-- Linha 228
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000260'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '3CDKPcoHjQmkY2vb2w==',
  senhaIv = 'uElOZLxO37sDkgyX',
  senhaTag = '46JBxyz8634t3pNt0RpXfw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 228 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000260', NULL, '-----',
  '3CDKPcoHjQmkY2vb2w==', 'uElOZLxO37sDkgyX', '46JBxyz8634t3pNt0RpXfw==', 'Origem: planilha de senhas de oficinas, linha 228 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260', 1
WHERE @portalCredentialId IS NULL;

-- Linha 229
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'H6BaKP44uyGO9f8d',
  senhaIv = '5XG2B7yTnxbZtg+D',
  senhaTag = 'WewKGDOselzBIBjZhv4Sjg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 229 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'H6BaKP44uyGO9f8d', '5XG2B7yTnxbZtg+D', 'WewKGDOselzBIBjZhv4Sjg==', 'Origem: planilha de senhas de oficinas, linha 229 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 232
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '38948027824'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'drtiwsmlbJkMAg==',
  senhaIv = '7g+HX9LbgzfE0cEj',
  senhaTag = 'rimCJyUgmwQ+YpqSS5eY0Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 232 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 38948027824',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '38948027824', NULL, '-----',
  'drtiwsmlbJkMAg==', '7g+HX9LbgzfE0cEj', 'rimCJyUgmwQ+YpqSS5eY0Q==', 'Origem: planilha de senhas de oficinas, linha 232 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 38948027824', 1
WHERE @portalCredentialId IS NULL;

-- Linha 233
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000477'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'r4/EUGascGW0',
  senhaIv = 'vJOMJuOBrrmnsbtI',
  senhaTag = 'UK4MtpAW5E6Y3SzWXZYF7w==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 233 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000477', NULL, '-----',
  'r4/EUGascGW0', 'vJOMJuOBrrmnsbtI', 'UK4MtpAW5E6Y3SzWXZYF7w==', 'Origem: planilha de senhas de oficinas, linha 233 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477', 1
WHERE @portalCredentialId IS NULL;

-- Linha 235
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000124'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'GqoxtE7gGOdb',
  senhaIv = 'L2OIyznVsu6HDUgO',
  senhaTag = 'JeQb06mXePibrjjZ1fJD1g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 235 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000124', NULL, '-----',
  'GqoxtE7gGOdb', 'L2OIyznVsu6HDUgO', 'JeQb06mXePibrjjZ1fJD1g==', 'Origem: planilha de senhas de oficinas, linha 235 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124', 1
WHERE @portalCredentialId IS NULL;

-- Linha 236
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '38948027824'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'BRE5puEy3YXZcg==',
  senhaIv = 'qTqU7eJs3hi3LfFA',
  senhaTag = 'RJ3uD6TjDB+pUoKJ9tPJiQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 236 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 38948027824',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '38948027824', NULL, '-----',
  'BRE5puEy3YXZcg==', 'qTqU7eJs3hi3LfFA', 'RJ3uD6TjDB+pUoKJ9tPJiQ==', 'Origem: planilha de senhas de oficinas, linha 236 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 38948027824', 1
WHERE @portalCredentialId IS NULL;

-- Linha 237
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000736'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'uAPe1n0iHmYJItQ=',
  senhaIv = 'SEa6R17QiQIfXerN',
  senhaTag = 'Wu4OtmZOlYGKaSfPtOv2rQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 237 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000736', NULL, '-----',
  'uAPe1n0iHmYJItQ=', 'SEa6R17QiQIfXerN', 'Wu4OtmZOlYGKaSfPtOv2rQ==', 'Origem: planilha de senhas de oficinas, linha 237 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736', 1
WHERE @portalCredentialId IS NULL;

-- Linha 239
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000169'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'RDKgMIGtVvEqKtGlSxU=',
  senhaIv = '94KCv7WS2UIP/fie',
  senhaTag = '9b0FBdwXbPe/fgqCERbjeQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 239 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000169', NULL, '-----',
  'RDKgMIGtVvEqKtGlSxU=', '94KCv7WS2UIP/fie', '9b0FBdwXbPe/fgqCERbjeQ==', 'Origem: planilha de senhas de oficinas, linha 239 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169', 1
WHERE @portalCredentialId IS NULL;

-- Linha 240
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '43404787846'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Vrr2GKZp0/g=',
  senhaIv = 'moig1Ah1uMdB0SvO',
  senhaTag = 'jUEXFe6CoyNeGWdE7B8iXQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 240 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 43404787846',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '43404787846', NULL, '-----',
  'Vrr2GKZp0/g=', 'moig1Ah1uMdB0SvO', 'jUEXFe6CoyNeGWdE7B8iXQ==', 'Origem: planilha de senhas de oficinas, linha 240 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 43404787846', 1
WHERE @portalCredentialId IS NULL;

-- Linha 241
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Tokio'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Tokio'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000320'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'VqYXKireMAUmbA==',
  senhaIv = 'WHjyD6NTB3zkluIs',
  senhaTag = 'bEBrd/b/2j4JsUdlBtfzNA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 241 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 24464151000320',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000320', NULL, '-----',
  'VqYXKireMAUmbA==', 'WHjyD6NTB3zkluIs', 'bEBrd/b/2j4JsUdlBtfzNA==', 'Origem: planilha de senhas de oficinas, linha 241 | Segmento: OFICINA | Seguradora: TOKIO MARINE (Ofc) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 24464151000320', 1
WHERE @portalCredentialId IS NULL;

-- Linha 242
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '27596439000185'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'cNCIV5eRTlOzqA==',
  senhaIv = 'pRf1953eYR6yaKdY',
  senhaTag = 'GAutMDF3cUaDQM88tcdz5g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 242 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '27596439000185', NULL, '-----',
  'cNCIV5eRTlOzqA==', 'pRf1953eYR6yaKdY', 'GAutMDF3cUaDQM88tcdz5g==', 'Origem: planilha de senhas de oficinas, linha 242 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ACTION Araraquara | CNPJ: 27.596.439/0001-85 | Acesso original: 27596439000185', 1
WHERE @portalCredentialId IS NULL;

-- Linha 243
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001387'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'UX58p0M4RnfeNw==',
  senhaIv = '+OU/6JT7zcrSmPaL',
  senhaTag = 'TRh5+sLJ9UJuT9x9zVh6Sg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 243 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001387', NULL, '-----',
  'UX58p0M4RnfeNw==', '+OU/6JT7zcrSmPaL', 'TRh5+sLJ9UJuT9x9zVh6Sg==', 'Origem: planilha de senhas de oficinas, linha 243 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Araraquara | CNPJ: 46.101.424/0013-87 | Acesso original: 46101424001387', 1
WHERE @portalCredentialId IS NULL;

-- Linha 244
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424000143'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Bd1QwtWPrUflFQ==',
  senhaIv = '1OCdwvaw4Ni8tA5v',
  senhaTag = 'xzAj+kH2T4AmecE89nhR0Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 244 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424000143', NULL, '-----',
  'Bd1QwtWPrUflFQ==', '1OCdwvaw4Ni8tA5v', 'xzAj+kH2T4AmecE89nhR0Q==', 'Origem: planilha de senhas de oficinas, linha 244 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Ribeirão Preto | CNPJ: 46.101.424/0001-43 | Acesso original: 46101424000143', 1
WHERE @portalCredentialId IS NULL;

-- Linha 245
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001549'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'zGZ5vxKuZHms4A==',
  senhaIv = 'DtkLIqTvIEEW8eVK',
  senhaTag = 'vrf+HdQLYUnUfkjI6hE5JQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 245 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001549', NULL, '-----',
  'zGZ5vxKuZHms4A==', 'DtkLIqTvIEEW8eVK', 'vrf+HdQLYUnUfkjI6hE5JQ==', 'Origem: planilha de senhas de oficinas, linha 245 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ATRI Santos | CNPJ: 46.101.424/0015-49 | Acesso original: 46101424001549', 1
WHERE @portalCredentialId IS NULL;

-- Linha 246
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '22220764000206'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'siXCnFH62j5tcA==',
  senhaIv = '2k58XiCAIpbVCrrC',
  senhaTag = 'b77tsss5DIXsBr7UT+kZvw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 246 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '22220764000206', NULL, '-----',
  'siXCnFH62j5tcA==', '2k58XiCAIpbVCrrC', 'b77tsss5DIXsBr7UT+kZvw==', 'Origem: planilha de senhas de oficinas, linha 246 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: AUDI RP | CNPJ: 22.220.764/0002-06 | Acesso original: 22220764000206', 1
WHERE @portalCredentialId IS NULL;

-- Linha 247
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '384141001399'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'fLVPoYIOpiCTj+w=',
  senhaIv = 'SzdOcckE1PJE82Hp',
  senhaTag = 'xbuy1tqNqnyam4F+pyxijw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 247 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO Barretos | CNPJ: 00.384.141/0013-99 | Acesso original: 384141001399',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '384141001399', NULL, '-----',
  'fLVPoYIOpiCTj+w=', 'SzdOcckE1PJE82Hp', 'xbuy1tqNqnyam4F+pyxijw==', 'Origem: planilha de senhas de oficinas, linha 247 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO Barretos | CNPJ: 00.384.141/0013-99 | Acesso original: 384141001399', 1
WHERE @portalCredentialId IS NULL;

-- Linha 248
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '384141000902'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'JvZkNeJa7eJW5AM=',
  senhaIv = '1j25T3oo/BNxSHpO',
  senhaTag = 'cinsad5CAcJFOJHxZ56cOw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 248 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 384141000902',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '384141000902', NULL, '-----',
  'JvZkNeJa7eJW5AM=', '1j25T3oo/BNxSHpO', 'cinsad5CAcJFOJHxZ56cOw==', 'Origem: planilha de senhas de oficinas, linha 248 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO Franca | CNPJ: 00.384.141/0009-02 | Acesso original: 384141000902', 1
WHERE @portalCredentialId IS NULL;

-- Linha 249
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '00384141000155'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '2cBtVhErHvfkew==',
  senhaIv = 'bgZDwfADzR3q1F2g',
  senhaTag = 'yVoX5WUGC+RI7qmfZrx+kw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 249 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '00384141000155', NULL, '-----',
  '2cBtVhErHvfkew==', 'bgZDwfADzR3q1F2g', 'yVoX5WUGC+RI7qmfZrx+kw==', 'Origem: planilha de senhas de oficinas, linha 249 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: EURO RP | CNPJ: 00.384.141/0001-55 | Acesso original: 00384141000155', 1
WHERE @portalCredentialId IS NULL;

-- Linha 250
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '43197396000111'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'x7HdXBtth2hkDg==',
  senhaIv = 'o1ZaE+64dga3BRk7',
  senhaTag = 'QqVApN2P7VvTOZv17MQJIg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 250 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '43197396000111', NULL, '-----',
  'x7HdXBtth2hkDg==', 'o1ZaE+64dga3BRk7', 'QqVApN2P7VvTOZv17MQJIg==', 'Origem: planilha de senhas de oficinas, linha 250 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: GT8 Chery Franca | CNPJ: 43.197.396/0001-11 | Acesso original: 43197396000111', 1
WHERE @portalCredentialId IS NULL;

-- Linha 251
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002197'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = '87+0gEiuu97Ekg==',
  senhaIv = 'Y1ylUZf3zCa1BHMv',
  senhaTag = 'Ef8K538ICbBWP4hn4MmRaA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 251 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002197', NULL, '-----',
  '87+0gEiuu97Ekg==', 'Y1ylUZf3zCa1BHMv', 'Ef8K538ICbBWP4hn4MmRaA==', 'Origem: planilha de senhas de oficinas, linha 251 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP Araraquara | CNPJ: 46.101.424/0021-97 | Acesso original: 46101424002197', 1
WHERE @portalCredentialId IS NULL;

-- Linha 252
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424002359'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'PvANBIBNzqWXjA==',
  senhaIv = 'eygxn5oKBafRJu9q',
  senhaTag = '6eBD4/JiZkucRU25O76sKw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 252 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424002359', NULL, '-----',
  'PvANBIBNzqWXjA==', 'eygxn5oKBafRJu9q', '6eBD4/JiZkucRU25O76sKw==', 'Origem: planilha de senhas de oficinas, linha 252 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP Franca | CNPJ: 46.101.424/0023-59 | Acesso original: 46101424002359', 1
WHERE @portalCredentialId IS NULL;

-- Linha 253
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '46101424001891'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'wQkTLw4yXqDKww==',
  senhaIv = 'Qz/jbN96//KtKeIQ',
  senhaTag = '+t72VAK8egPmSjRvlu17/Q==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 253 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '46101424001891', NULL, '-----',
  'wQkTLw4yXqDKww==', 'Qz/jbN96//KtKeIQ', '+t72VAK8egPmSjRvlu17/Q==', 'Origem: planilha de senhas de oficinas, linha 253 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: JEEP RP | CNPJ: 46.101.424/0018-91 | Acesso original: 46101424001891', 1
WHERE @portalCredentialId IS NULL;

-- Linha 254
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '08982781000179'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'r2w4FPsa',
  senhaIv = 'yZugzHfSFKKl0kl6',
  senhaTag = '0iZtBLQ/qzDgTVPPzKy7vA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 254 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '08982781000179', NULL, '-----',
  'r2w4FPsa', 'yZugzHfSFKKl0kl6', '0iZtBLQ/qzDgTVPPzKy7vA==', 'Origem: planilha de senhas de oficinas, linha 254 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: KOI Honda | CNPJ: 08.982.781/0001-79 | Acesso original: 08982781000179', 1
WHERE @portalCredentialId IS NULL;

-- Linha 255
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000421'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Z3u/iR89jOPZ9Q==',
  senhaIv = '7CTVTEpqH3t5cDyK',
  senhaTag = 'GQnbGXeblUmoTq3TR6cEdQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 255 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000421', NULL, '-----',
  'Z3u/iR89jOPZ9Q==', '7CTVTEpqH3t5cDyK', 'GQnbGXeblUmoTq3TR6cEdQ==', 'Origem: planilha de senhas de oficinas, linha 255 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Araraquara | CNPJ: 15.917.899/0004-21 | Acesso original: 15917899000421', 1
WHERE @portalCredentialId IS NULL;

-- Linha 256
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000693'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'eJ8unaYxYMqe9g==',
  senhaIv = 'rNJEWKbNLaKV7Avj',
  senhaTag = 'LyrVDa1Y/AtjAPyp4MTJNA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 256 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000693', NULL, '-----',
  'eJ8unaYxYMqe9g==', 'rNJEWKbNLaKV7Avj', 'LyrVDa1Y/AtjAPyp4MTJNA==', 'Origem: planilha de senhas de oficinas, linha 256 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Barretos | CNPJ: 15.917.899/0006-93 | Acesso original: 15917899000693', 1
WHERE @portalCredentialId IS NULL;

-- Linha 257
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000340'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'h8d0jI50uLxfYg==',
  senhaIv = 'xEZZ3wQUUdFnOoEQ',
  senhaTag = '5V5R5pqrD464NkBptgOcwg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 257 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000340', NULL, '-----',
  'h8d0jI50uLxfYg==', 'xEZZ3wQUUdFnOoEQ', '5V5R5pqrD464NkBptgOcwg==', 'Origem: planilha de senhas de oficinas, linha 257 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Castelo | CNPJ: 15.917.899/0003-40 | Acesso original: 15917899000340', 1
WHERE @portalCredentialId IS NULL;

-- Linha 258
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000260'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'aUaxPGVyTG1c',
  senhaIv = 'Mn9RBwQdXo5BKUYH',
  senhaTag = 'sXEK/HAu17f84ZGZJIIOug==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 258 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000260', NULL, '-----',
  'aUaxPGVyTG1c', 'Mn9RBwQdXo5BKUYH', 'sXEK/HAu17f84ZGZJIIOug==', 'Origem: planilha de senhas de oficinas, linha 258 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Franca | CNPJ: 15.917.899/0002-60 | Acesso original: 15917899000260', 1
WHERE @portalCredentialId IS NULL;

-- Linha 259
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000189'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'inAWuqeix7A=',
  senhaIv = '+3RQV2ajVz83XwiP',
  senhaTag = '08Bw1VhKMU6++0e2ZSr96g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 259 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000189', NULL, '-----',
  'inAWuqeix7A=', '+3RQV2ajVz83XwiP', '08Bw1VhKMU6++0e2ZSr96g==', 'Origem: planilha de senhas de oficinas, linha 259 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Matriz | CNPJ: 15.917.899/0001-89 | Acesso original: 15917899000189', 1
WHERE @portalCredentialId IS NULL;

-- Linha 260
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '15917899000774'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'If0ADVzy2ICdRDVY',
  senhaIv = 'hfA04TuxxbDJU/TG',
  senhaTag = 'M7lB4gf81SvHFZTmlGkVkg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 260 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: 15917899000774',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '15917899000774', NULL, '-----',
  'If0ADVzy2ICdRDVY', 'hfA04TuxxbDJU/TG', 'M7lB4gf81SvHFZTmlGkVkg==', 'Origem: planilha de senhas de oficinas, linha 260 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NEW Sertãozinho | CNPJ: 15.917.899/0007-74 | Acesso original: 15917899000774', 1
WHERE @portalCredentialId IS NULL;

-- Linha 261
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000225'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'lRG5HCLnXRcViQ==',
  senhaIv = 'rqzJN+PiyGHcpiNp',
  senhaTag = 'h6ubqExwRYdEaakyY4elEA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 261 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000225', NULL, '-----',
  'lRG5HCLnXRcViQ==', 'rqzJN+PiyGHcpiNp', 'h6ubqExwRYdEaakyY4elEA==', 'Origem: planilha de senhas de oficinas, linha 261 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NISSAN Keiji Franca | CNPJ: 25.277.607/0002-25 | Acesso original: 25277607000225', 1
WHERE @portalCredentialId IS NULL;

-- Linha 262
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '25277607000144'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'WDciuATP/qak7A==',
  senhaIv = 'JqDkiCWT2fddQCFj',
  senhaTag = 'Tp0T4BktqOOCfkYR4tp4qg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 262 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '25277607000144', NULL, '-----',
  'WDciuATP/qak7A==', 'JqDkiCWT2fddQCFj', 'Tp0T4BktqOOCfkYR4tp4qg==', 'Origem: planilha de senhas de oficinas, linha 262 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: NISSAN Keiji RP | CNPJ: 25.277.607/0001-44 | Acesso original: 25277607000144', 1
WHERE @portalCredentialId IS NULL;

-- Linha 263
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000477'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Y9sT41wS1wJedw==',
  senhaIv = 'KBJQ6NFedOPUoEm7',
  senhaTag = 'k3JyBN0SF8tbKc8HSYJWLw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 263 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000477', NULL, '-----',
  'Y9sT41wS1wJedw==', 'KBJQ6NFedOPUoEm7', 'k3JyBN0SF8tbKc8HSYJWLw==', 'Origem: planilha de senhas de oficinas, linha 263 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ONTAKE Barretos | CNPJ: 24.896.001/0004-77 | Acesso original: 24896001000477', 1
WHERE @portalCredentialId IS NULL;

-- Linha 264
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24896001000124'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'pbOgbrjPLnU65A==',
  senhaIv = 'dyvGeiYRjlSFpeti',
  senhaTag = 'YMgt3Mi+cNY9uBG3yr4w8g==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 264 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24896001000124', NULL, '-----',
  'pbOgbrjPLnU65A==', 'dyvGeiYRjlSFpeti', 'YMgt3Mi+cNY9uBG3yr4w8g==', 'Origem: planilha de senhas de oficinas, linha 264 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ONTAKE Toyota | CNPJ: 24.896.001/0001-24 | Acesso original: 24896001000124', 1
WHERE @portalCredentialId IS NULL;

-- Linha 265
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749001201'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'c1NdWeHkhXUx3g==',
  senhaIv = 'P1iWKXdOiulcnD5m',
  senhaTag = 'ZfAVTYTew/vM/OWwAsbTGA==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 265 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 49226749001201',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749001201', NULL, '-----',
  'c1NdWeHkhXUx3g==', 'P1iWKXdOiulcnD5m', 'ZfAVTYTew/vM/OWwAsbTGA==', 'Origem: planilha de senhas de oficinas, linha 265 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Estoque) RP | CNPJ: 49.226.749/0012-01 | Acesso original: 49226749001201', 1
WHERE @portalCredentialId IS NULL;

-- Linha 266
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000140'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'ilt+gR6UCx2//Q==',
  senhaIv = 'ZdiHDmz45IqbmHvN',
  senhaTag = 'kecDd0xCo9RMvE95iZOtww==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 266 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000140', NULL, '-----',
  'ilt+gR6UCx2//Q==', 'ZdiHDmz45IqbmHvN', 'kecDd0xCo9RMvE95iZOtww==', 'Origem: planilha de senhas de oficinas, linha 266 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Vcl) RP | CNPJ: 49.226.749/0001-40 | Acesso original: 49226749000140', 1
WHERE @portalCredentialId IS NULL;

-- Linha 268
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '49226749000736'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'Kh54tvoZHtbg3A==',
  senhaIv = 'pQbVXJPYjs1XdaS/',
  senhaTag = 'bxpjV3P3ADMxPKgbYoxeOw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 268 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '49226749000736', NULL, '-----',
  'Kh54tvoZHtbg3A==', 'pQbVXJPYjs1XdaS/', 'bxpjV3P3ADMxPKgbYoxeOw==', 'Origem: planilha de senhas de oficinas, linha 268 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: ORTOVEL (Vcl) UBL | CNPJ: 49.226.749/0007-36 | Acesso original: 49226749000736', 1
WHERE @portalCredentialId IS NULL;

-- Linha 269
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000169'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'sfcl9OD6mFpvbQ==',
  senhaIv = '+QP+UxSil6jy+O8S',
  senhaTag = 'PwogK9n0LgyfNHvN9aqcPw==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 269 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000169', NULL, '-----',
  'sfcl9OD6mFpvbQ==', '+QP+UxSil6jy+O8S', 'PwogK9n0LgyfNHvN9aqcPw==', 'Origem: planilha de senhas de oficinas, linha 269 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo RP | CNPJ: 24.464.151/0001-69 | Acesso original: 24464151000169', 1
WHERE @portalCredentialId IS NULL;

-- Linha 270
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000240'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'XScHfJYLt1r8YQ==',
  senhaIv = 'xbCwf1l7K65fgPOZ',
  senhaTag = 'XBSU6CHhgfo2GEFMk6TeHg==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 270 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000240', NULL, '-----',
  'XScHfJYLt1r8YQ==', 'xbCwf1l7K65fgPOZ', 'XBSU6CHhgfo2GEFMk6TeHg==', 'Origem: planilha de senhas de oficinas, linha 270 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo SJRP | CNPJ: 24.464.151/0002-40 | Acesso original: 24464151000240', 1
WHERE @portalCredentialId IS NULL;

-- Linha 271
SET @seguradoraId := (
  SELECT id
  FROM seguradoras
  WHERE LOWER(TRIM(nome)) = LOWER(TRIM('Yelum'))
     OR LOWER(TRIM(codigo)) = LOWER(TRIM('Yelum'))
  ORDER BY id
  LIMIT 1
);
SET @portalCredentialId := (
  SELECT id
  FROM portais_senhas
  WHERE portalNome = '24464151000320'
    AND usuario = '-----'
  ORDER BY id
  LIMIT 1
);
UPDATE portais_senhas
SET
  seguradoraId = @seguradoraId,
  portalUrl = NULL,
  senhaCriptografada = 'InGIsQWg6Ic=',
  senhaIv = 'BR71QZJHTiYUn+g1',
  senhaTag = 'xKkG4IF83xTmclY58xWgFQ==',
  observacao = 'Origem: planilha de senhas de oficinas, linha 271 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 24464151000320',
  ativo = 1,
  atualizadoEm = CURRENT_TIMESTAMP
WHERE id = @portalCredentialId;
INSERT INTO portais_senhas (
  seguradoraId, portalNome, portalUrl, usuario,
  senhaCriptografada, senhaIv, senhaTag, observacao, ativo
)
SELECT
  @seguradoraId, '24464151000320', NULL, '-----',
  'InGIsQWg6Ic=', 'BR71QZJHTiYUn+g1', 'xKkG4IF83xTmclY58xWgFQ==', 'Origem: planilha de senhas de oficinas, linha 271 | Segmento: OFICINA | Seguradora: YELUM (Ofc) | Empresa: THOR Volvo UBL | CNPJ: 24.464.151/0003-20 | Acesso original: 24464151000320', 1
WHERE @portalCredentialId IS NULL;

COMMIT;

SELECT
  246 AS linhas_validas_processadas,
  24 AS linhas_ignoradas;
