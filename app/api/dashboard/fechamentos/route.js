import { NextResponse } from "next/server";
import { prisma } from "../../../../lib/prisma";
import { currency, dateKey, increment, normalizeJson, safeError, sortObjectEntries } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_FECHAMENTOS");
  if (!auth.ok) return auth.response;

  try {
    const fechamentoRows = await prisma.$queryRaw`
      SELECT
        f.id,
        f.os,
        f.decisao,
        f.statusFechamento,
        f.valorAprovado,
        f.ocorrencias,
        f.anexos,
        f.respostaApi,
        f.erro,
        c.seguradora,
        c.statusConsolidacao,
        c.acaoSugerida,
        c.execucaoId,
        c.gatesValidacao,
        c.dadosConference,
        c.dadosExtraidos,
        c.validacoes,
        c.resultadoJson,
        e.nome AS empresaNome,
        c.curadorAprovado,
        DATE_FORMAT(c.curadorAprovadoEm, '%Y-%m-%dT%H:%i:%s') AS curadorAprovadoEm,
        c.curadorResponsavel,
        (
          SELECT COUNT(*)
          FROM fechamentos f_retornos
          WHERE f_retornos.os = f.os
            AND (
              f_retornos.decisao = 'RETORNAR_OFICINA'
              OR f_retornos.statusFechamento = 'FECHADA_REPROVADA_RETORNO_OFICINA'
            )
        ) AS retornosOficina,
        DATE_FORMAT(f.criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(f.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm
      FROM fechamentos f
      LEFT JOIN consolidacoes c ON c.os = f.os
      LEFT JOIN empresas e ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
      ORDER BY f.atualizadoEm DESC
      LIMIT 500
    `;

    const pendingReturnRows = await prisma.$queryRaw`
      SELECT
        CONCAT('decisao-', d.id) AS id,
        c.os,
        d.decisao,
        'PENDENTE_PASSO_3' AS statusFechamento,
        0 AS valorAprovado,
        JSON_ARRAY(JSON_OBJECT('comentario', d.observacao)) AS ocorrencias,
        JSON_ARRAY() AS anexos,
        JSON_OBJECT('pendente', true, 'origem', 'decisoes_humanas') AS respostaApi,
        NULL AS erro,
        c.seguradora,
        c.statusConsolidacao,
        c.acaoSugerida,
        c.execucaoId,
        c.gatesValidacao,
        c.dadosConference,
        c.dadosExtraidos,
        c.validacoes,
        c.resultadoJson,
        e.nome AS empresaNome,
        c.curadorAprovado,
        DATE_FORMAT(c.curadorAprovadoEm, '%Y-%m-%dT%H:%i:%s') AS curadorAprovadoEm,
        c.curadorResponsavel,
        (
          SELECT COUNT(*)
          FROM fechamentos f_retornos
          WHERE f_retornos.os = c.os
            AND (
              f_retornos.decisao = 'RETORNAR_OFICINA'
              OR f_retornos.statusFechamento = 'FECHADA_REPROVADA_RETORNO_OFICINA'
            )
        ) AS retornosOficina,
        DATE_FORMAT(d.criadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(d.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm
      FROM consolidacoes c
      LEFT JOIN empresas e ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
      INNER JOIN (
        SELECT d1.*
        FROM decisoes_humanas d1
        INNER JOIN (
          SELECT os, MAX(criadoEm) AS criadoEm
          FROM decisoes_humanas
          GROUP BY os
        ) ult
          ON ult.os = d1.os
         AND ult.criadoEm = d1.criadoEm
      ) d ON d.os = c.os
      WHERE d.decisao = 'VOLTAR_OS'
        AND COALESCE(c.ativoConferencia, 1) = 1
        AND c.statusConsolidacao <> 'ENCERRADO_MANUALMENTE'
        AND NOT EXISTS (
          SELECT 1
          FROM fechamentos f
          WHERE f.os = c.os
            AND f.statusFechamento IN (
              'FECHADA_APROVADA',
              'FECHADA_REPROVADA_RETORNO_OFICINA',
              'FECHADA_ANALISE_MANUAL',
              'ENCERRADO_MANUALMENTE',
              'PENDENTE_PASSO_3'
            )
            AND f.atualizadoEm >= c.atualizadoEm
        )
      ORDER BY d.atualizadoEm DESC
      LIMIT 500
    `;

    const pendingApprovalRows = await prisma.$queryRaw`
      SELECT
        CONCAT('curadoria-', c.id) AS id,
        c.os,
        'APROVAR' AS decisao,
        'PENDENTE_PASSO_3' AS statusFechamento,
        COALESCE(
          CAST(JSON_UNQUOTE(JSON_EXTRACT(c.validacoes, '$.orcamento.dados.orcamento.valor_servicos')) AS DECIMAL(12, 2)),
          CAST(JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.valor_servicos')) AS DECIMAL(12, 2)),
          0
        ) AS valorAprovado,
        COALESCE(JSON_EXTRACT(c.dadosExtraidos, '$.ocorrencias_passo3'), JSON_ARRAY()) AS ocorrencias,
        JSON_ARRAY() AS anexos,
        JSON_OBJECT('pendente', true, 'origem', 'curadoria') AS respostaApi,
        NULL AS erro,
        c.seguradora,
        c.statusConsolidacao,
        c.acaoSugerida,
        c.execucaoId,
        c.gatesValidacao,
        c.dadosConference,
        c.dadosExtraidos,
        c.validacoes,
        c.resultadoJson,
        e.nome AS empresaNome,
        c.curadorAprovado,
        DATE_FORMAT(c.curadorAprovadoEm, '%Y-%m-%dT%H:%i:%s') AS curadorAprovadoEm,
        c.curadorResponsavel,
        (
          SELECT COUNT(*)
          FROM fechamentos f_retornos
          WHERE f_retornos.os = c.os
            AND (
              f_retornos.decisao = 'RETORNAR_OFICINA'
              OR f_retornos.statusFechamento = 'FECHADA_REPROVADA_RETORNO_OFICINA'
            )
        ) AS retornosOficina,
        DATE_FORMAT(c.curadorAprovadoEm, '%Y-%m-%dT%H:%i:%s') AS criadoEm,
        DATE_FORMAT(c.atualizadoEm, '%Y-%m-%dT%H:%i:%s') AS atualizadoEm
      FROM consolidacoes c
      LEFT JOIN empresas e ON e.codigo = JSON_UNQUOTE(JSON_EXTRACT(c.dadosConference, '$.empresa'))
      WHERE c.curadorAprovado = 1
        AND COALESCE(c.ativoConferencia, 1) = 1
        AND c.statusConsolidacao <> 'ENCERRADO_MANUALMENTE'
        AND NOT EXISTS (
          SELECT 1
          FROM fechamentos f
          WHERE f.os = c.os
            AND f.statusFechamento IN (
              'FECHADA_APROVADA',
              'FECHADA_REPROVADA_RETORNO_OFICINA',
              'FECHADA_ANALISE_MANUAL',
              'ENCERRADO_MANUALMENTE',
              'PENDENTE_PASSO_3'
            )
            AND f.atualizadoEm >= c.atualizadoEm
        )
      ORDER BY c.atualizadoEm DESC
      LIMIT 500
    `;

    const rows = [...pendingReturnRows, ...pendingApprovalRows, ...fechamentoRows]
      .sort((a, b) => new Date(b.atualizadoEm || 0) - new Date(a.atualizadoEm || 0))
      .slice(0, 500);

    return NextResponse.json(buildFechamentosDashboard(rows));
  } catch (error) {
    return NextResponse.json({
      ok: false,
      error: safeError(error),
      totals: { total: 0, valorAprovado: 0, erros: 0, pendentes: 0 },
      timeline: [],
      byStatus: [],
      byDecision: [],
      items: [],
    });
  }
}

function buildFechamentosDashboard(rows) {
  const byStatus = {};
  const byDecision = {};
  const timeline = {};
  const items = [];
  let valorAprovado = 0;

  for (const row of rows) {
    const dadosConference = normalizeJson(row.dadosConference);
    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const validacoes = normalizeJson(row.validacoes);
    const gatesValidacao = normalizeJson(row.gatesValidacao);
    const valor = currency(row.valorAprovado);
    const status = row.statusFechamento || "NAO_INFORMADO";
    const retornosOficina = Number(row.retornosOficina || 0);
    const statusConsolidacaoBase = normalizeStatus(row.statusConsolidacao);
    const manualPorRecorrencia = retornosOficina > 3 && !hasManualAdjustment(dadosExtraidos);
    const statusConsolidacao = manualPorRecorrencia && statusConsolidacaoBase !== "PENDENTE_COMPLEMENTO_MANUAL"
      ? "PENDENTE_COMPLEMENTO_MANUAL"
      : statusConsolidacaoBase;
    const data = dateKey(row.atualizadoEm);
    const timelineItem = timeline[data] || { data, total: 0, valor: 0, fechados: 0, erros: 0 };
    timelineItem.total += 1;
    timelineItem.valor = currency(timelineItem.valor + valor);
    if (status.includes("ERRO")) timelineItem.erros += 1;
    else timelineItem.fechados += 1;
    timeline[data] = timelineItem;

    increment(byStatus, status);
    increment(byDecision, row.decisao || "NAO_INFORMADA");
    valorAprovado = currency(valorAprovado + valor);

    items.push({
      id: row.id,
      os: row.os,
      codigoConference: row.os,
      osObjeto: displayOs(dadosConference, row.os),
      seguradora: row.seguradora,
      empresa: dadosConference.empresa || "",
      empresaNome: row.empresaNome || "",
      chassi: dadosConference.chassi || "",
      placa: dadosConference.placa || "",
      decisao: row.decisao,
      status,
      statusConsolidacao,
      statusOriginal: row.statusConsolidacao,
      statusOperacional: statusConsolidacao,
      retornosOficina,
      acao: row.acaoSugerida,
      execucaoId: row.execucaoId,
      valorAprovado: valor,
      ocorrencias: normalizeJson(row.ocorrencias),
      anexos: normalizeJson(row.anexos),
      respostaApi: normalizeJson(row.respostaApi),
      erro: row.erro,
      gatesValidacao,
      validacoes,
      dadosConference,
      dadosExtraidos,
      curadoria: {
        aprovado: Boolean(row.curadorAprovado),
        aprovadoEm: toIso(row.curadorAprovadoEm),
        responsavel: row.curadorResponsavel,
      },
      criadoEm: toIso(row.criadoEm),
      atualizadoEm: toIso(row.atualizadoEm),
    });
  }

  return {
    ok: true,
    updatedAt: new Date().toISOString().slice(0, 19),
    totals: {
      total: rows.length,
      valorAprovado,
      erros: items.filter((item) => String(item.status || "").includes("ERRO")).length,
      pendentes: items.filter((item) => String(item.status || "").includes("PENDENTE")).length,
    },
    timeline: Object.values(timeline).sort((a, b) => a.data.localeCompare(b.data)),
    byStatus: sortObjectEntries(byStatus),
    byDecision: sortObjectEntries(byDecision),
    items,
  };
}

function toIso(value) {
  if (!value) return null;
  if (value instanceof Date) return value.toISOString();
  return String(value);
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

function normalizeStatus(status) {
  if (status === "FALHA_SINCRONIZACAO_NBS_FECHAR_MANUAL") return "REPROVADA_VALOR_DIVERGENTE";
  return status;
}

function hasManualAdjustment(dadosExtraidos) {
  const historico = dadosExtraidos?.ajustes_manuais;
  if (Array.isArray(historico) && historico.length > 0) return true;

  const atuais = dadosExtraidos?.ajustes_manuais_atuais;
  return Boolean(atuais && typeof atuais === "object" && Object.keys(atuais).length > 0);
}
