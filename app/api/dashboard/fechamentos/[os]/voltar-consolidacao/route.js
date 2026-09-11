import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "VOLTAR_FECHAMENTO_CONSOLIDACAO");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;

    const result = await prisma.$transaction(async (tx) => {
      const existing = await tx.$queryRaw`
        SELECT os, seguradora, dadosConference, dadosExtraidos
        FROM consolidacoes
        WHERE os = ${os}
        LIMIT 1
      `;

      if (!existing.length) {
        return null;
      }

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
          statusConsolidacao = 'NAO_PROCESSADO',
          acaoSugerida = 'AGUARDANDO_PASSO_1',
          execucaoId = NULL,
          gatesValidacao = JSON_OBJECT(),
          validacoes = JSON_OBJECT(),
          erros = JSON_ARRAY(),
          resultadoJson = JSON_OBJECT(
            'os', os,
            'seguradora', seguradora,
            'status_consolidacao', 'NAO_PROCESSADO',
            'acao_sugerida', 'AGUARDANDO_PASSO_1',
            'validacoes', JSON_OBJECT(),
            'dados_conference', COALESCE(dadosConference, JSON_OBJECT()),
            'dados_extraidos', COALESCE(dadosExtraidos, JSON_OBJECT()),
            'erros', JSON_ARRAY()
          ),
          curadorAprovado = 0,
          curadorAprovadoEm = NULL,
          curadorResponsavel = NULL,
          ativoConferencia = 1,
          atualizadoEm = CURRENT_TIMESTAMP
        WHERE os = ${os}
      `;

      return { pendingFechamentos, decisions, updated };
    });

    if (!result) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para voltar a consolidacao.", os }, { status: 404 });
    }

    return NextResponse.json({
      ok: true,
      os,
      statusConsolidacao: "NAO_PROCESSADO",
      acaoSugerida: "AGUARDANDO_PASSO_1",
      resetado: result,
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}
