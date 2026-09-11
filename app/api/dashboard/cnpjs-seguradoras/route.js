import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";
import { safeError } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_CNPJS");
  if (!auth.ok) return auth.response;

  try {
    const [empresas, seguradoras, regras] = await Promise.all([
      prisma.$queryRaw`
        SELECT id, codigo, nome, cnpj
        FROM empresas
        ORDER BY COALESCE(nome, codigo), codigo
      `,
      prisma.$queryRaw`
        SELECT id, codigo, nome, cnpj
        FROM seguradoras
        ORDER BY COALESCE(nome, codigo), codigo
      `,
      prisma.$queryRaw`
        SELECT
          esc.id,
          esc.ativo,
          DATE_FORMAT(esc.criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
          DATE_FORMAT(esc.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm,
          e.id AS empresaId,
          e.codigo AS empresaCodigo,
          e.nome AS empresaNome,
          e.cnpj AS empresaCnpj,
          s.id AS seguradoraId,
          s.codigo AS seguradoraCodigo,
          s.nome AS seguradoraNome,
          s.cnpj AS seguradoraCnpjCadastro,
          sc.id AS seguradoraCnpjId,
          sc.cnpj AS cnpj,
          sc.grupo AS grupo
        FROM empresa_seguradora_cnpj esc
        JOIN empresas e ON e.id = esc.empresaId
        JOIN seguradoras_cnpj sc ON sc.id = esc.seguradoraCnpjId
        JOIN seguradoras s ON s.id = sc.seguradoraId
        ORDER BY e.nome, s.nome, sc.cnpj
      `,
    ]);

    return NextResponse.json({
      ok: true,
      empresas: empresas.map(normalizeCadastro),
      seguradoras: seguradoras.map(normalizeCadastro),
      items: regras.map(normalizeRegra),
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error), empresas: [], seguradoras: [], items: [] }, { status: 500 });
  }
}

export async function POST(request) {
  const auth = requirePermission(request, "MANAGE_CNPJS");
  if (!auth.ok) return auth.response;

  try {
    const payload = await request.json();
    const result = await salvarRegra(payload);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function PUT(request) {
  const auth = requirePermission(request, "MANAGE_CNPJS");
  if (!auth.ok) return auth.response;

  try {
    const payload = await request.json();
    const id = Number(payload.id);
    if (!Number.isInteger(id) || id <= 0) {
      return NextResponse.json({ ok: false, error: "ID da regra invalido." }, { status: 400 });
    }

    const result = await salvarRegra(payload, id);
    return NextResponse.json({ ok: true, item: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

export async function DELETE(request) {
  const auth = requirePermission(request, "MANAGE_CNPJS");
  if (!auth.ok) return auth.response;

  try {
    const { searchParams } = new URL(request.url);
    const id = Number(searchParams.get("id"));
    if (!Number.isInteger(id) || id <= 0) {
      return NextResponse.json({ ok: false, error: "ID da regra invalido." }, { status: 400 });
    }

    const deleted = await prisma.$executeRaw`
      DELETE FROM empresa_seguradora_cnpj
      WHERE id = ${id}
    `;

    if (!deleted) {
      return NextResponse.json({ ok: false, error: "Regra nao encontrada." }, { status: 404 });
    }

    return NextResponse.json({ ok: true, id });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

async function salvarRegra(payload, id = null) {
  const empresaId = parseId(payload.empresaId, "empresa");
  const seguradoraId = parseId(payload.seguradoraId, "seguradora");
  const cnpj = normalizeCnpj(payload.cnpj);
  const grupo = normalizeText(payload.grupo, 120);
  const ativo = payload.ativo === false || payload.ativo === 0 || payload.ativo === "0" ? 0 : 1;

  if (cnpj.length !== 14) {
    throw new Error("CNPJ deve conter 14 digitos.");
  }

  return prisma.$transaction(async (tx) => {
    const seguradoraRows = await tx.$queryRaw`
      SELECT id
      FROM seguradoras
      WHERE id = ${seguradoraId}
      LIMIT 1
    `;
    if (!seguradoraRows.length) throw new Error("Seguradora nao encontrada.");

    const empresaRows = await tx.$queryRaw`
      SELECT id
      FROM empresas
      WHERE id = ${empresaId}
      LIMIT 1
    `;
    if (!empresaRows.length) throw new Error("Empresa nao encontrada.");

    await tx.$executeRaw`
      INSERT INTO seguradoras_cnpj (
        seguradoraId,
        cnpj,
        grupo,
        dadosApi
      )
      VALUES (
        ${seguradoraId},
        ${cnpj},
        ${grupo},
        ${JSON.stringify({ origem: "dashboard" })}
      )
      ON DUPLICATE KEY UPDATE
        grupo = VALUES(grupo),
        atualizadoEm = CURRENT_TIMESTAMP
    `;

    const seguradoraCnpjRows = await tx.$queryRaw`
      SELECT id
      FROM seguradoras_cnpj
      WHERE seguradoraId = ${seguradoraId}
        AND cnpj = ${cnpj}
      LIMIT 1
    `;
    const seguradoraCnpjId = Number(seguradoraCnpjRows[0]?.id);
    if (!seguradoraCnpjId) throw new Error("Nao foi possivel gravar o CNPJ da seguradora.");

    if (id) {
      await tx.$executeRaw`
        UPDATE empresa_seguradora_cnpj
        SET
          empresaId = ${empresaId},
          seguradoraCnpjId = ${seguradoraCnpjId},
          ativo = ${ativo},
          atualizadoEm = CURRENT_TIMESTAMP
        WHERE id = ${id}
      `;
    } else {
      await tx.$executeRaw`
        INSERT INTO empresa_seguradora_cnpj (
          empresaId,
          seguradoraCnpjId,
          ativo,
          dadosApi
        )
        VALUES (
          ${empresaId},
          ${seguradoraCnpjId},
          ${ativo},
          ${JSON.stringify({ origem: "dashboard" })}
        )
        ON DUPLICATE KEY UPDATE
          ativo = VALUES(ativo),
          dadosApi = VALUES(dadosApi),
          atualizadoEm = CURRENT_TIMESTAMP
      `;
    }

    const rows = await tx.$queryRaw`
      SELECT
        esc.id,
        esc.ativo,
        DATE_FORMAT(esc.criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(esc.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm,
        e.id AS empresaId,
        e.codigo AS empresaCodigo,
        e.nome AS empresaNome,
        e.cnpj AS empresaCnpj,
        s.id AS seguradoraId,
        s.codigo AS seguradoraCodigo,
        s.nome AS seguradoraNome,
        s.cnpj AS seguradoraCnpjCadastro,
        sc.id AS seguradoraCnpjId,
        sc.cnpj AS cnpj,
        sc.grupo AS grupo
      FROM empresa_seguradora_cnpj esc
      JOIN empresas e ON e.id = esc.empresaId
      JOIN seguradoras_cnpj sc ON sc.id = esc.seguradoraCnpjId
      JOIN seguradoras s ON s.id = sc.seguradoraId
      WHERE esc.empresaId = ${empresaId}
        AND esc.seguradoraCnpjId = ${seguradoraCnpjId}
      LIMIT 1
    `;

    return normalizeRegra(rows[0]);
  });
}

function parseId(value, label) {
  const id = Number(value);
  if (!Number.isInteger(id) || id <= 0) {
    throw new Error(`Informe uma ${label} valida.`);
  }
  return id;
}

function normalizeCnpj(value) {
  return String(value || "").replace(/\D/g, "");
}

function normalizeText(value, maxLength) {
  const text = String(value || "").trim();
  return text ? text.slice(0, maxLength) : null;
}

function normalizeCadastro(row) {
  return {
    id: Number(row.id),
    codigo: row.codigo || "",
    nome: row.nome || "",
    cnpj: row.cnpj || "",
  };
}

function normalizeRegra(row) {
  return {
    id: Number(row.id),
    ativo: Boolean(row.ativo),
    empresaId: Number(row.empresaId),
    empresaCodigo: row.empresaCodigo || "",
    empresaNome: row.empresaNome || "",
    empresaCnpj: row.empresaCnpj || "",
    seguradoraId: Number(row.seguradoraId),
    seguradoraCodigo: row.seguradoraCodigo || "",
    seguradoraNome: row.seguradoraNome || "",
    seguradoraCnpjCadastro: row.seguradoraCnpjCadastro || "",
    seguradoraCnpjId: Number(row.seguradoraCnpjId),
    cnpj: row.cnpj || "",
    grupo: row.grupo || "",
    criadoEm: row.criadoEm || null,
    atualizadoEm: row.atualizadoEm || null,
  };
}
