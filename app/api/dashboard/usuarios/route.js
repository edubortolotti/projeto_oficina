import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";
import { safeError } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_USUARIOS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const rows = await prisma.$queryRaw`
      SELECT
        id,
        nome,
        email,
        login,
        perfil,
        adUsuario,
        dominio,
        ativo,
        senhaHash,
        DATE_FORMAT(criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm
      FROM sistema_usuarios
      ORDER BY nome, login
    `;

    return NextResponse.json({ ok: true, items: rows.map(normalizeUser) });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error), items: [] }, { status: 500 });
  }
}

export async function POST(request) {
  const auth = requirePermission(request, "MANAGE_USUARIOS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const payload = await request.json();
    const result = await salvarUsuario(payload);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function PUT(request) {
  const auth = requirePermission(request, "MANAGE_USUARIOS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const payload = await request.json();
    const id = parseId(payload.id, "usuario");
    const result = await salvarUsuario(payload, id);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function DELETE(request) {
  const auth = requirePermission(request, "MANAGE_USUARIOS");
  if (!auth.ok) return auth.response;

  try {
    await ensureSchema();
    const { searchParams } = new URL(request.url);
    const id = parseId(searchParams.get("id"), "usuario");

    const deleted = await prisma.$executeRaw`
      DELETE FROM sistema_usuarios
      WHERE id = ${id}
    `;

    if (!deleted) {
      return NextResponse.json({ ok: false, error: "Usuario nao encontrado." }, { status: 404 });
    }

    return NextResponse.json({ ok: true, id });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

async function ensureSchema() {
  await prisma.$executeRaw`
    CREATE TABLE IF NOT EXISTS sistema_usuarios (
      id INT NOT NULL AUTO_INCREMENT,
      nome VARCHAR(160) NOT NULL,
      email VARCHAR(180) NULL,
      login VARCHAR(120) NOT NULL,
      perfil VARCHAR(40) NOT NULL DEFAULT 'OPERADOR',
      adUsuario TINYINT(1) NOT NULL DEFAULT 0,
      dominio VARCHAR(120) NULL,
      senhaHash VARCHAR(255) NULL,
      senhaSalt VARCHAR(64) NULL,
      ativo TINYINT(1) NOT NULL DEFAULT 1,
      criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY sistema_usuarios_login_key (login),
      KEY sistema_usuarios_perfil_idx (perfil),
      KEY sistema_usuarios_adUsuario_idx (adUsuario)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `;
}

async function salvarUsuario(payload, id = null) {
  const nome = normalizeRequiredText(payload.nome, "Nome", 160);
  const email = normalizeText(payload.email, 180);
  const login = normalizeLogin(payload.login);
  const perfil = normalizePerfil(payload.perfil);
  const adUsuario = 1;
  const dominio = null;
  const ativo = payload.ativo === false || payload.ativo === 0 || payload.ativo === "0" ? 0 : 1;

  return prisma.$transaction(async (tx) => {
    if (id) {
      const existingRows = await tx.$queryRaw`
        SELECT id
        FROM sistema_usuarios
        WHERE id = ${id}
        LIMIT 1
      `;
      if (!existingRows.length) throw new Error("Usuario nao encontrado.");

      await tx.$executeRaw`
        UPDATE sistema_usuarios
        SET
          nome = ${nome},
          email = ${email},
          login = ${login},
          perfil = ${perfil},
          adUsuario = ${adUsuario},
          dominio = ${dominio},
          senhaHash = NULL,
          senhaSalt = NULL,
          ativo = ${ativo},
          atualizadoEm = CURRENT_TIMESTAMP
        WHERE id = ${id}
      `;
    } else {
      await tx.$executeRaw`
        INSERT INTO sistema_usuarios (
          nome,
          email,
          login,
          perfil,
          adUsuario,
          dominio,
          senhaHash,
          senhaSalt,
          ativo
        )
        VALUES (
          ${nome},
          ${email},
          ${login},
          ${perfil},
          ${adUsuario},
          ${dominio},
          NULL,
          NULL,
          ${ativo}
        )
      `;
    }

    const rows = await tx.$queryRaw`
      SELECT
        id,
        nome,
        email,
        login,
        perfil,
        adUsuario,
        dominio,
        ativo,
        senhaHash,
        DATE_FORMAT(criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm
      FROM sistema_usuarios
      WHERE login = ${login}
      LIMIT 1
    `;

    return normalizeUser(rows[0]);
  });
}

function parseId(value, label) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    throw new Error(`Informe um ${label} valido.`);
  }
  return id;
}

function normalizeLogin(value) {
  const login = String(value || "").trim().toLowerCase();
  if (!login) throw new Error("Login e obrigatorio.");
  if (login.length > 120) return login.slice(0, 120);
  return login;
}

function normalizePerfil(value) {
  const perfil = String(value || "OPERADOR").trim().toUpperCase();
  const allowed = new Set(["ADMIN", "CURADOR", "OPERADOR", "LEITURA"]);
  if (!allowed.has(perfil)) {
    throw new Error("Perfil invalido.");
  }
  return perfil;
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

function normalizeUser(row) {
  return {
    id: Number(row.id),
    nome: row.nome || "",
    email: row.email || "",
    login: row.login || "",
    perfil: row.perfil || "OPERADOR",
    adUsuario: Boolean(row.adUsuario),
    dominio: row.dominio || "",
    hasSenha: Boolean(row.senhaHash),
    ativo: Boolean(row.ativo),
    criadoEm: row.criadoEm || null,
    atualizadoEm: row.atualizadoEm || null,
  };
}
