import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "RETORNAR_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const body = await request.json().catch(() => ({}));
    const observacao = String(body.observacao || "").trim();

    if (!observacao) {
      return NextResponse.json({ ok: false, error: "Informe o comentario para a ocorrencia." }, { status: 400 });
    }

    const existing = await prisma.$queryRaw`
      SELECT os, statusConsolidacao, acaoSugerida
      FROM consolidacoes
      WHERE os = ${os}
      LIMIT 1
    `;

    if (!existing.length) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para retorno.", os }, { status: 404 });
    }

    await prisma.$transaction([
      prisma.decisaoHumana.create({
        data: {
          os,
          decisao: "VOLTAR_OS",
          observacao,
          responsavel: auth.session.login || auth.session.nome || "curador",
          dadosDecisao: {
            origem: "dashboard_consolidacoes",
            destino: "passo_3_retorno",
            ocorrencia: observacao,
            statusConsolidacao: existing[0].statusConsolidacao,
            acaoSugeridaAnterior: existing[0].acaoSugerida,
          },
        },
      }),
      prisma.$executeRaw`
        UPDATE consolidacoes
        SET
          acaoSugerida = 'RETORNAR_OFICINA',
          atualizadoEm = CURRENT_TIMESTAMP
        WHERE os = ${os}
      `,
    ]);

    return NextResponse.json({
      ok: true,
      os,
      decisao: "VOLTAR_OS",
      observacao,
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}
