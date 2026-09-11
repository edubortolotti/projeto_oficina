import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";
import {
  dateKey,
  getConferenceStatus,
  increment,
  isEncerradoManualmente,
  normalizeJson,
  safeError,
  sortObjectEntries,
} from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_EXECUCOES");
  if (!auth.ok) return auth.response;

  try {
    const rows = await prisma.$queryRaw`
      SELECT
        id,
        os,
        seguradora,
        statusConsolidacao,
        acaoSugerida,
        gatesValidacao,
        dadosConference,
        dadosExtraidos,
        validacoes,
        erros,
        DATE_FORMAT(iniciadoEm, '%Y-%m-%dT%H:%i:%s') AS iniciadoEm,
        DATE_FORMAT(finalizadoEm, '%Y-%m-%dT%H:%i:%s') AS finalizadoEm
      FROM execucoes_consolidacao
      ORDER BY finalizadoEm DESC
      LIMIT 500
    `;

    return NextResponse.json(buildExecucoesDashboard(rows));
  } catch (error) {
    return NextResponse.json({
      ok: false,
      error: safeError(error),
      totals: { total: 0, encerradasManualmente: 0, comErro: 0 },
      timeline: [],
      byStatus: [],
      byAction: [],
      items: [],
    });
  }
}

function buildExecucoesDashboard(rows) {
  const byStatus = {};
  const byAction = {};
  const timeline = {};
  const items = [];
  let encerradasManualmente = 0;
  let comErro = 0;

  for (const row of rows) {
    const dadosConference = normalizeJson(row.dadosConference);
    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const validacoes = normalizeJson(row.validacoes);
    const erros = normalizeJson(row.erros);
    const status = row.statusConsolidacao || "NAO_INFORMADO";
    const conferenceStatus = getConferenceStatus(dadosConference);
    const encerradoManualmente = isEncerradoManualmente(dadosConference);
    const statusOperacional = encerradoManualmente ? "ENCERRADO_MANUALMENTE" : status;
    const data = dateKey(row.finalizadoEm);
    const timelineItem = timeline[data] || { data, total: 0, encerradasManualmente: 0, erros: 0 };

    timelineItem.total += 1;
    if (encerradoManualmente) timelineItem.encerradasManualmente += 1;
    if (status.includes("ERRO") || Object.keys(erros).length > 0) timelineItem.erros += 1;
    timeline[data] = timelineItem;

    if (encerradoManualmente) encerradasManualmente += 1;
    if (status.includes("ERRO") || Object.keys(erros).length > 0) comErro += 1;
    increment(byStatus, statusOperacional);
    increment(byAction, row.acaoSugerida || "NAO_INFORMADA");

    items.push({
      id: row.id,
      codigoConference: row.os,
      os: displayOs(dadosConference, row.os),
      seguradora: row.seguradora,
      empresa: dadosConference.empresa || "",
      chassi: dadosConference.chassi || "",
      placa: dadosConference.placa || "",
      status,
      statusOperacional,
      encerradoManualmente,
      conferenceStatus,
      acao: row.acaoSugerida,
      gatesValidacao: normalizeJson(row.gatesValidacao),
      dadosConference,
      dadosExtraidos,
      validacoes,
      erros,
      iniciadoEm: toIso(row.iniciadoEm),
      finalizadoEm: toIso(row.finalizadoEm),
    });
  }

  return {
    ok: true,
    updatedAt: new Date().toISOString().slice(0, 19),
    totals: {
      total: rows.length,
      encerradasManualmente,
      comErro,
    },
    timeline: Object.values(timeline).sort((a, b) => a.data.localeCompare(b.data)),
    byStatus: sortObjectEntries(byStatus),
    byAction: sortObjectEntries(byAction),
    items,
  };
}

function displayOs(dadosConference, fallback) {
  return (
    dadosConference?.osObjeto ||
    dadosConference?.os_objeto ||
    dadosConference?.os_atri ||
    dadosConference?.raw?.os ||
    dadosConference?.raw?.ordem_servico ||
    dadosConference?.raw?.numero_os ||
    dadosConference?.os ||
    fallback
  );
}

function toIso(value) {
  if (!value) return null;
  if (value instanceof Date) return value.toISOString();
  return String(value);
}
