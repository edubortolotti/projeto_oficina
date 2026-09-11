import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "AJUSTAR_VALORES_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const body = await request.json().catch(() => ({}));
    const comentario = String(body.comentario || "").trim();
    const id = String(body.id || "MANUAL").trim() || "MANUAL";

    if (!comentario) {
      return NextResponse.json({ ok: false, error: "Informe o texto da ocorrencia.", os }, { status: 400 });
    }

    const row = await loadConsolidacao(os);
    if (!row) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para ajuste de ocorrencia.", os }, { status: 404 });
    }

    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const responsavel = auth.session.login || auth.session.nome || "curador";
    const alteradoEm = new Date().toISOString();
    const ocorrencia = {
      id,
      comentario,
      origem: "curadoria_manual",
      responsavel,
      criadoEm: alteradoEm,
    };

    dadosExtraidos.ocorrencias_passo3 = [...currentOccurrences(dadosExtraidos), ocorrencia];
    dadosExtraidos.ocorrencias_manuais = [
      ...manualHistory(dadosExtraidos),
      { acao: "INSERIR", ocorrencia, responsavel, alteradoEm },
    ];

    await saveDadosExtraidos(os, dadosExtraidos);

    return NextResponse.json({ ok: true, os, ocorrencia });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}

export async function DELETE(request, { params }) {
  const auth = requirePermission(request, "AJUSTAR_VALORES_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const body = await request.json().catch(() => ({}));
    const index = Number(body.index);

    if (!Number.isInteger(index) || index < 0) {
      return NextResponse.json({ ok: false, error: "Informe uma ocorrencia valida para remover.", os }, { status: 400 });
    }

    const row = await loadConsolidacao(os);
    if (!row) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para ajuste de ocorrencia.", os }, { status: 404 });
    }

    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const ocorrencias = currentOccurrences(dadosExtraidos);
    const removida = ocorrencias[index];

    if (!removida) {
      return NextResponse.json({ ok: false, error: "Ocorrencia nao encontrada para remover.", os }, { status: 404 });
    }

    const responsavel = auth.session.login || auth.session.nome || "curador";
    const alteradoEm = new Date().toISOString();
    dadosExtraidos.ocorrencias_passo3 = ocorrencias.filter((_, itemIndex) => itemIndex !== index);
    dadosExtraidos.ocorrencias_manuais = [
      ...manualHistory(dadosExtraidos),
      { acao: "REMOVER", ocorrencia: removida, index, responsavel, alteradoEm },
    ];

    await saveDadosExtraidos(os, dadosExtraidos);

    return NextResponse.json({ ok: true, os, removida });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}

async function loadConsolidacao(os) {
  const rows = await prisma.$queryRaw`
    SELECT os, dadosExtraidos
    FROM consolidacoes
    WHERE os = ${os}
      AND COALESCE(ativoConferencia, 1) = 1
    LIMIT 1
  `;
  return rows[0];
}

async function saveDadosExtraidos(os, dadosExtraidos) {
  await prisma.$executeRaw`
    UPDATE consolidacoes
    SET
      dadosExtraidos = ${JSON.stringify(dadosExtraidos)},
      curadorAprovado = 0,
      curadorAprovadoEm = NULL,
      curadorResponsavel = NULL,
      atualizadoEm = CURRENT_TIMESTAMP
    WHERE os = ${os}
  `;
}

function currentOccurrences(dadosExtraidos) {
  return Array.isArray(dadosExtraidos.ocorrencias_passo3) ? dadosExtraidos.ocorrencias_passo3 : [];
}

function manualHistory(dadosExtraidos) {
  return Array.isArray(dadosExtraidos.ocorrencias_manuais) ? dadosExtraidos.ocorrencias_manuais : [];
}

function normalizeJson(value) {
  if (!value) return {};
  if (typeof value === "object") return value;
  try {
    return JSON.parse(value);
  } catch {
    return {};
  }
}
