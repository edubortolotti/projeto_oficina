import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "CANCELAR_FECHAMENTO");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;

    const fechamentoFinal = await prisma.$queryRaw`
      SELECT id, statusFechamento
      FROM fechamentos
      WHERE os = ${os}
        AND statusFechamento IN (
          'FECHADA_APROVADA',
          'FECHADA_REPROVADA_RETORNO_OFICINA',
          'FECHADA_ANALISE_MANUAL',
          'ENCERRADO_MANUALMENTE'
        )
      LIMIT 1
    `;

    if (fechamentoFinal.length) {
      return NextResponse.json(
        { ok: false, error: "Nao e possivel cancelar uma acao ja executada no Passo 3.", os },
        { status: 409 },
      );
    }

    const result = await prisma.$transaction(async (tx) => {
      const pendingFechamentos = await tx.$executeRaw`
        DELETE FROM fechamentos
        WHERE os = ${os}
          AND statusFechamento = 'PENDENTE_PASSO_3'
      `;

      const decisions = await tx.$executeRaw`
        DELETE FROM decisoes_humanas
        WHERE os = ${os}
          AND decisao = 'VOLTAR_OS'
      `;

      const updated = await tx.$executeRaw`
        UPDATE consolidacoes
        SET
          curadorAprovado = 0,
          curadorAprovadoEm = NULL,
          curadorResponsavel = NULL,
          acaoSugerida = CASE
            WHEN acaoSugerida = 'RETORNAR_OFICINA' THEN 'ENVIAR_PARA_PASSO_2'
            ELSE acaoSugerida
          END,
          atualizadoEm = CURRENT_TIMESTAMP
        WHERE os = ${os}
      `;

      return { pendingFechamentos, decisions, updated };
    });

    if (!result.updated && !result.decisions && !result.pendingFechamentos) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para cancelamento.", os }, { status: 404 });
    }

    return NextResponse.json({ ok: true, os, cancelado: result });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}
