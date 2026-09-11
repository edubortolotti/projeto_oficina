import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "APROVAR_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const result = await prisma.$executeRaw`
      UPDATE consolidacoes
      SET
        curadorAprovado = 1,
        curadorAprovadoEm = CURRENT_TIMESTAMP,
        curadorResponsavel = ${auth.session.login || auth.session.nome || "curador"},
        atualizadoEm = CURRENT_TIMESTAMP
      WHERE os = ${os}
    `;

    if (Number(result) === 0) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para aprovacao.", os }, { status: 404 });
    }

    const rows = await prisma.$queryRaw`
      SELECT
        os,
        curadorAprovado,
        DATE_FORMAT(curadorAprovadoEm, '%Y-%m-%dT%H:%i:%s') AS curadorAprovadoEm,
        curadorResponsavel
      FROM consolidacoes
      WHERE os = ${os}
      LIMIT 1
    `;
    const row = rows[0] || {};

    return NextResponse.json({
      ok: true,
      os: row.os || os,
      curadoria: {
        aprovado: Boolean(row.curadorAprovado),
        aprovadoEm: toIso(row.curadorAprovadoEm),
        responsavel: row.curadorResponsavel,
      },
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}

function toIso(value) {
  if (!value) return null;
  if (value instanceof Date) return value.toISOString();
  return String(value);
}
