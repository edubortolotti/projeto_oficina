import crypto from "node:crypto";
import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";
import { safeError } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const response = await fetch(`${baseUrl}/dashboard/portais-senhas`, {
      method: "GET",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler portais e senhas.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        {
          ok: false,
          error: payload.detail || payload.error || "Falha ao carregar portais e senhas.",
          seguradoras: [],
          items: [],
        },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json(payload);
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error), seguradoras: [], items: [] }, { status: 500 });
  }
}

export async function POST(request) {
  const auth = requirePermission(request, "MANAGE_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const payload = await request.json();
    const result = await salvarSenhaPortal(payload);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function PUT(request) {
  const auth = requirePermission(request, "MANAGE_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const payload = await request.json();
    const id = parseId(payload.id, "credencial");
    const result = await salvarSenhaPortal(payload, id);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function DELETE(request) {
  const auth = requirePermission(request, "MANAGE_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const { searchParams } = new URL(request.url);
    const id = parseId(searchParams.get("id"), "credencial");

    const deleted = await prisma.$executeRaw`
      DELETE FROM portais_senhas
      WHERE id = ${id}
    `;

    if (!deleted) {
      return NextResponse.json({ ok: false, error: "Credencial nao encontrada." }, { status: 404 });
    }

    return NextResponse.json({ ok: true, id });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

async function ensureSchema() {
  await prisma.$executeRaw`
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
  `;
  await ensureColumn("portais_senhas", "empresaId", "INT NULL");
  await ensureColumn("portais_senhas", "segmento", "VARCHAR(80) NULL");
  await ensureColumn("portais_senhas", "empresaNome", "VARCHAR(180) NULL");
  await ensureColumn("portais_senhas", "cnpj", "VARCHAR(14) NULL");
  await ensureIndex("portais_senhas", "portais_senhas_empresaId_idx", "empresaId");
  await ensureIndex("portais_senhas", "portais_senhas_empresa_seguradora_idx", "empresaId, seguradoraId");
}

async function ensureColumn(table, column, definition) {
  try {
    await prisma.$executeRawUnsafe(`ALTER TABLE ${table} ADD COLUMN ${column} ${definition}`);
  } catch (error) {
    if (!String(error?.message || error).includes("Duplicate column") && !String(error?.message || error).includes("1060")) {
      throw error;
    }
  }
}

async function ensureIndex(table, indexName, columns) {
  try {
    await prisma.$executeRawUnsafe(`ALTER TABLE ${table} ADD INDEX ${indexName} (${columns})`);
  } catch (error) {
    if (!String(error?.message || error).includes("Duplicate key name") && !String(error?.message || error).includes("1061")) {
      throw error;
    }
  }
}

async function salvarSenhaPortal(payload, id = null) {
  const empresaId = payload.empresaId ? parseId(payload.empresaId, "empresa") : null;
  const seguradoraId = payload.seguradoraId ? parseId(payload.seguradoraId, "seguradora") : null;
  const segmento = normalizeText(payload.segmento, 80);
  const empresaNome = normalizeText(payload.empresaNome || payload.empresa, 180);
  const cnpj = normalizeCnpj(payload.cnpj);
  const portalNome = normalizeRequiredText(payload.portalNome, "Nome do portal", 120);
  const portalUrl = normalizeText(payload.portalUrl, 255);
  const usuario = normalizeRequiredText(payload.usuario, "Usuario", 180);
  const observacao = normalizeText(payload.observacao, 1000);
  const ativo = payload.ativo === false || payload.ativo === 0 || payload.ativo === "0" ? 0 : 1;
  const senha = String(payload.senha || "");

  if (!id && !senha) {
    throw new Error("Informe a senha do portal.");
  }

  return prisma.$transaction(async (tx) => {
    if (empresaId) {
      const empresaRows = await tx.$queryRaw`
        SELECT id
        FROM empresas
        WHERE id = ${empresaId}
        LIMIT 1
      `;
      if (!empresaRows.length) throw new Error("Empresa nao encontrada.");
    }

    if (seguradoraId) {
      const seguradoraRows = await tx.$queryRaw`
        SELECT id
        FROM seguradoras
        WHERE id = ${seguradoraId}
        LIMIT 1
      `;
      if (!seguradoraRows.length) throw new Error("Seguradora nao encontrada.");
    }

    if (id) {
      const existingRows = await tx.$queryRaw`
        SELECT id
        FROM portais_senhas
        WHERE id = ${id}
        LIMIT 1
      `;
      if (!existingRows.length) throw new Error("Credencial nao encontrada.");

      if (senha) {
        const encrypted = encryptPassword(senha);
        await tx.$executeRaw`
          UPDATE portais_senhas
          SET
            empresaId = ${empresaId},
            seguradoraId = ${seguradoraId},
            segmento = ${segmento},
            empresaNome = ${empresaNome},
            cnpj = ${cnpj},
            portalNome = ${portalNome},
            portalUrl = ${portalUrl},
            usuario = ${usuario},
            senhaCriptografada = ${encrypted.encrypted},
            senhaIv = ${encrypted.iv},
            senhaTag = ${encrypted.tag},
            observacao = ${observacao},
            ativo = ${ativo},
            atualizadoEm = CURRENT_TIMESTAMP
          WHERE id = ${id}
        `;
      } else {
        await tx.$executeRaw`
          UPDATE portais_senhas
          SET
            empresaId = ${empresaId},
            seguradoraId = ${seguradoraId},
            segmento = ${segmento},
            empresaNome = ${empresaNome},
            cnpj = ${cnpj},
            portalNome = ${portalNome},
            portalUrl = ${portalUrl},
            usuario = ${usuario},
            observacao = ${observacao},
            ativo = ${ativo},
            atualizadoEm = CURRENT_TIMESTAMP
          WHERE id = ${id}
        `;
      }
    } else {
      const encrypted = encryptPassword(senha);
      await tx.$executeRaw`
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
          ${empresaId},
          ${seguradoraId},
          ${segmento},
          ${empresaNome},
          ${cnpj},
          ${portalNome},
          ${portalUrl},
          ${usuario},
          ${encrypted.encrypted},
          ${encrypted.iv},
          ${encrypted.tag},
          ${observacao},
          ${ativo}
        )
      `;
    }

    const rows = await tx.$queryRaw`
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
      WHERE p.portalNome = ${portalNome}
        AND p.usuario = ${usuario}
        AND (p.empresaId <=> ${empresaId})
        AND (p.seguradoraId <=> ${seguradoraId})
      ORDER BY p.atualizadoEm DESC
      LIMIT 1
    `;

    return normalizeCredential(rows[0]);
  });
}

function encryptPassword(password) {
  const secret = process.env.PORTAL_CREDENTIALS_SECRET || process.env.APP_SECRET || process.env.NEXTAUTH_SECRET;
  if (!secret || secret.length < 16) {
    throw new Error("Configure PORTAL_CREDENTIALS_SECRET com pelo menos 16 caracteres para salvar senhas.");
  }

  const key = crypto.createHash("sha256").update(secret).digest();
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const encrypted = Buffer.concat([cipher.update(password, "utf8"), cipher.final()]);
  const tag = cipher.getAuthTag();

  return {
    encrypted: encrypted.toString("base64"),
    iv: iv.toString("base64"),
    tag: tag.toString("base64"),
  };
}

function parseId(value, label) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    throw new Error(`Informe uma ${label} valida.`);
  }
  return id;
}

function normalizeRequiredText(value, label, maxLength) {
  const text = normalizeText(value, maxLength);
  if (!text) throw new Error(`${label} e obrigatorio.`);
  return text;
}

function normalizeText(value, maxLength) {
  const text = String(value || "").trim();
  return text ? text.slice(0, maxLength) : null;
}

function normalizeCnpj(value) {
  const digits = String(value || "").replace(/\D+/g, "");
  return digits ? digits.slice(0, 14) : null;
}

function normalizeSeguradora(row) {
  return {
    id: Number(row.id),
    codigo: row.codigo || "",
    nome: row.nome || "",
    cnpj: row.cnpj || "",
  };
}

function normalizeCredential(row) {
  const importWarnings = parseImportWarnings(row.observacao);
  return {
    id: Number(row.id),
    empresaId: row.empresaId ? Number(row.empresaId) : null,
    empresaCodigo: row.empresaCodigo || "",
    empresaNomeCadastro: row.empresaNomeCadastro || "",
    segmento: row.segmento || "",
    empresaNome: row.empresaNome || "",
    cnpj: row.cnpj || "",
    seguradoraId: row.seguradoraId ? Number(row.seguradoraId) : null,
    seguradoraCodigo: row.seguradoraCodigo || "",
    seguradoraNome: row.seguradoraNome || "",
    portalNome: row.portalNome || "",
    portalUrl: row.portalUrl || "",
    usuario: row.usuario || "",
    hasSenha: Boolean(row.senhaCriptografada),
    observacao: row.observacao || "",
    importWarnings,
    ativo: Boolean(row.ativo),
    criadoEm: row.criadoEm || null,
    atualizadoEm: row.atualizadoEm || null,
  };
}

function parseImportWarnings(observacao) {
  if (!observacao) return [];
  try {
    const payload = JSON.parse(observacao);
    return Array.isArray(payload.avisos) ? payload.avisos.filter(Boolean).map(String) : [];
  } catch {
    return [];
  }
}

async function parseJsonResponse(response, fallbackMessage) {
  const text = await response.text();
  if (!text) return {};

  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`${fallbackMessage} HTTP ${response.status}: ${textPreview(text)}`);
  }
}

function textPreview(text) {
  return String(text)
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 220) || "resposta vazia ou invalida";
}
