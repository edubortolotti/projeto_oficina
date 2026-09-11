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
    const campo = String(body.campo || "").trim();
    const valor = body.valor;

    if (!["cnpj", "valor_pecas", "valor_servicos", "valor_franquia"].includes(campo)) {
      return NextResponse.json({ ok: false, error: "Campo de ajuste invalido.", os }, { status: 400 });
    }

    const rows = await prisma.$queryRaw`
      SELECT
        c.os,
        c.statusConsolidacao,
        c.gatesValidacao,
        c.dadosConference,
        c.dadosExtraidos,
        c.validacoes
      FROM consolidacoes c
      WHERE c.os = ${os}
        AND COALESCE(c.ativoConferencia, 1) = 1
      LIMIT 1
    `;

    const row = rows[0];
    if (!row) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para ajuste.", os }, { status: 404 });
    }

    const dadosConference = normalizeJson(row.dadosConference);
    const dadosExtraidos = normalizeJson(row.dadosExtraidos);
    const validacoes = normalizeJson(row.validacoes);
    const gatesValidacao = normalizeJson(row.gatesValidacao);
    const responsavel = auth.session.login || auth.session.nome || "curador";
    const ajuste = {
      campo,
      valor,
      responsavel,
      ajustadoEm: new Date().toISOString(),
      origem: "dashboard_detalhe_os",
    };

    if (campo === "cnpj") {
      const cnpj = String(valor || "").replace(/\D/g, "");
      if (cnpj.length !== 14) {
        return NextResponse.json({ ok: false, error: "Informe um CNPJ com 14 digitos.", os }, { status: 400 });
      }
      const orcamento = ensureOrcamento(validacoes);
      orcamento.dados_faturamento = { ...(orcamento.dados_faturamento || {}), cnpj };
      dadosExtraidos.orcamento = applyManualAdjustmentToExtractedBudget(dadosExtraidos.orcamento, campo, cnpj, orcamento);
      validacoes.cnpj = {
        item: "cnpj",
        status: "APROVADO",
        mensagem: `CNPJ ${formatCnpj(cnpj)} ajustado manualmente pela curadoria.`,
        dados: {
          ...(validacoes.cnpj?.dados || {}),
          cnpj_correto: cnpj,
          cnpj_orcamento: cnpj,
          decisao_manual: "AJUSTADO",
          responsavel,
        },
      };
      gatesValidacao.cnpj = {
        ...(gatesValidacao.cnpj || {}),
        key: "cnpj",
        label: "CNPJ",
        status: "APROVADO",
        mensagem: `CNPJ ${formatCnpj(cnpj)} ajustado manualmente pela curadoria.`,
        dados: { ...(gatesValidacao.cnpj?.dados || {}), cnpj_correto: cnpj, cnpj_orcamento: cnpj },
      };
    }

    if (["valor_pecas", "valor_servicos", "valor_franquia"].includes(campo)) {
      const valorAjustado = parseMoney(valor);
      if (valorAjustado === null) {
        return NextResponse.json({ ok: false, error: "Informe um valor valido.", os }, { status: 400 });
      }
      ajuste.valorNormalizado = valorAjustado;
      const orcamento = ensureOrcamento(validacoes);
      Object.assign(orcamento, recalculateBudgetValues(orcamento, campo, valorAjustado));
      orcamento.ajustes_manuais = {
        ...(orcamento.ajustes_manuais || {}),
        [campo]: { valor: valorAjustado, responsavel, ajustadoEm: ajuste.ajustadoEm },
      };
      dadosExtraidos.orcamento = applyManualAdjustmentToExtractedBudget(dadosExtraidos.orcamento, campo, valorAjustado, orcamento);

      const comparacoes = recalculateComparisons(dadosConference, orcamento);
      const temDivergencia = comparacoes.some((comparacao) => !comparacao.confere);
      validacoes.orcamento.status = temDivergencia ? "REPROVADO" : "APROVADO";
      validacoes.orcamento.mensagem = temDivergencia
        ? "Divergencia entre valores do Conference e orcamento anexado."
        : "Valores do Conference conferem com o orcamento anexado.";
      validacoes.orcamento.dados.comparacoes = comparacoes;

      gatesValidacao.orcamento = {
        ...(gatesValidacao.orcamento || {}),
        key: "orcamento",
        label: "Orçamento",
        status: validacoes.orcamento.status,
        mensagem: "Batimento recalculado com ajuste manual da curadoria.",
        dados: {
          ...(gatesValidacao.orcamento?.dados || {}),
          comparacoes,
          orcamento,
        },
      };
      if (campo === "valor_franquia") {
        const comparacaoFranquia = comparacoes.find((comparacao) => comparacao.campo === "valor_franquia");
        gatesValidacao.valor_franquia = {
          ...(gatesValidacao.valor_franquia || {}),
          key: "valor_franquia",
          label: "Valor da franquia",
          status: comparacaoFranquia?.confere ? "APROVADO" : "REPROVADO",
          mensagem: comparacaoFranquia?.confere ? "Valor confere no batimento." : "Valor diverge no batimento.",
          dados: {
            conference: comparacaoFranquia?.conference,
            orcamento: comparacaoFranquia?.orcamento,
            diferenca: comparacaoFranquia?.diferenca,
          },
        };
      }
    }

    dadosExtraidos.ajustes_manuais = [...(Array.isArray(dadosExtraidos.ajustes_manuais) ? dadosExtraidos.ajustes_manuais : []), ajuste];
    dadosExtraidos.ajustes_manuais_atuais = {
      ...(dadosExtraidos.ajustes_manuais_atuais || {}),
      [campo]: ajuste,
    };
    const classificacao = classifyValidacoes(validacoes);
    dadosExtraidos.ocorrencias_passo3 = applyManualOccurrenceOverrides(
      buildOccurrencesFromValidations(
        validacoes,
        dadosConference,
        dadosExtraidos.orcamento,
        classificacao.statusConsolidacao,
      ),
      dadosExtraidos.ocorrencias_manuais,
    );

    await prisma.$executeRaw`
      UPDATE consolidacoes
      SET
        statusConsolidacao = ${classificacao.statusConsolidacao},
        acaoSugerida = ${classificacao.acaoSugerida},
        gatesValidacao = ${JSON.stringify(gatesValidacao)},
        dadosExtraidos = ${JSON.stringify(dadosExtraidos)},
        validacoes = ${JSON.stringify(validacoes)},
        curadorAprovado = 0,
        curadorAprovadoEm = NULL,
        curadorResponsavel = NULL,
        atualizadoEm = CURRENT_TIMESTAMP
      WHERE os = ${os}
    `;

    return NextResponse.json({
      ok: true,
      os,
      ajuste,
      statusConsolidacao: classificacao.statusConsolidacao,
      acaoSugerida: classificacao.acaoSugerida,
    });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
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

function parseMoney(value) {
  const normalized = String(value ?? "")
    .trim()
    .replace(/[^\d,.-]/g, "")
    .replace(/\./g, "")
    .replace(",", ".");
  const parsed = Number(normalized);
  return Number.isFinite(parsed) ? Math.round(parsed * 100) / 100 : null;
}

function ensureOrcamento(validacoes) {
  validacoes.orcamento = validacoes.orcamento || { item: "orcamento", status: "PENDENTE", mensagem: "", dados: {} };
  validacoes.orcamento.dados = validacoes.orcamento.dados || {};
  validacoes.orcamento.dados.orcamento = validacoes.orcamento.dados.orcamento || {};
  return validacoes.orcamento.dados.orcamento;
}

function recalculateBudgetValues(orcamento, campo, valorAjustado) {
  const next = { ...(orcamento || {}), [campo]: valorAjustado };
  const valorPecas = roundMoney(next.valor_pecas);
  const valorServicos = roundMoney(next.valor_servicos);
  const valorFranquia = roundMoney(next.valor_franquia);

  if (valorPecas !== null) next.valor_pecas = valorPecas;
  if (valorServicos !== null) next.valor_servicos = valorServicos;
  if (valorFranquia !== null) {
    next.valor_franquia = valorFranquia;
    next.valor_franquia_extraido = valorFranquia;
    next.valor_franquia_totalizador = valorFranquia;
  }

  if (valorPecas !== null && valorServicos !== null && valorFranquia !== null) {
    next.valor_total = roundMoney(valorPecas + valorServicos - valorFranquia);
  }

  return next;
}

function applyManualAdjustmentToExtractedBudget(payload, campo, valor, orcamento) {
  const next = cloneJson(payload) || {};

  if (campo === "cnpj") {
    next.dadosFaturamento = { ...(next.dadosFaturamento || {}), cnpj: valor };
    return next;
  }

  const base = ensureExtractedBudgetBase(next);
  const totais = base.totais;
  const faturar = totais.faturar;
  const deducoes = base.deducoes;

  faturar.pecas = roundMoney(orcamento.valor_pecas);
  faturar.servicos = roundMoney(orcamento.valor_servicos);
  faturar.total = roundMoney(orcamento.valor_total);
  deducoes.franquia_bruta = roundMoney(orcamento.valor_franquia);
  deducoes.total = roundMoney(orcamento.valor_franquia);

  if (orcamento.data_orcamento) {
    next.dados = { ...(next.dados || {}), dataOrcamento: orcamento.data_orcamento };
  }
  if (orcamento.sinistro) {
    next.dados = { ...(next.dados || {}), sinistro: orcamento.sinistro };
  }
  if (orcamento.dados_faturamento) {
    next.dadosFaturamento = { ...(next.dadosFaturamento || {}), ...orcamento.dados_faturamento };
  }

  return next;
}

function ensureExtractedBudgetBase(payload) {
  if (Array.isArray(payload.orcamento) && payload.orcamento.length > 0) {
    const base = payload.orcamento[0] || {};
    payload.orcamento[0] = base;
    base.totais = base.totais || {};
    base.totais.faturar = base.totais.faturar || {};
    base.deducoes = base.deducoes || {};
    return base;
  }

  const base = payload.liberado || {};
  payload.liberado = base;
  base.totais = base.totais || {};
  base.totais.faturar = base.totais.faturar || {};
  base.deducoes = base.deducoes || {};
  return base;
}

function cloneJson(value) {
  if (!value || typeof value !== "object") return value;
  try {
    return JSON.parse(JSON.stringify(value));
  } catch {
    return {};
  }
}

function recalculateComparisons(dadosConference, orcamento) {
  return ["valor_total", "valor_franquia"].map((campo) => {
    const conference = roundMoney(dadosConference?.[campo]);
    const valorOrcamento = roundMoney(orcamento?.[campo]);
    const diferenca = conference === null || valorOrcamento === null ? null : roundMoney(conference - valorOrcamento);
    return {
      campo,
      conference,
      orcamento: valorOrcamento,
      diferenca,
      confere: diferenca !== null && Math.abs(diferenca) <= 0.01,
    };
  });
}

function roundMoney(value) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? Math.round(parsed * 100) / 100 : null;
}

function buildOccurrencesFromValidations(validacoes, dadosConference, dadosOrcamento, statusConsolidacao) {
  const ocorrencias = [];
  const seguradora = dadosConference?.seguradora || "seguradora";
  const cnpj = validacoes.cnpj?.dados?.cnpj_correto
    || validacoes.orcamento?.dados?.orcamento?.dados_faturamento?.cnpj
    || dadosConference?.cnpj_seguradora;
  const cnpjFormatado = formatCnpj(cnpj);

  if (validacoes.anexos?.status === "REPROVADO") {
    ocorrencias.push({
      id: "C27",
      comentario: validacoes.anexos?.mensagem || "Anexos obrigatórios não foram encontrados. OS Reprovada, favor anexar os documentos.",
      origem: "anexos",
    });
  }

  if (validacoes.cnpj?.status === "APROVADO" && cnpj) {
    ocorrencias.push(
      { id: "C14", comentario: `CNPJ ${cnpjFormatado} esta Ativo, conforme consulta direta na Receita Federal.`, origem: "cnpj" },
      { id: "C15", comentario: `Processo será faturado no CNPJ ${cnpjFormatado} conforme região`, origem: "cnpj" },
      { id: "C16", comentario: `O CNPJ ${cnpjFormatado} confere com a empresa cadastrada.`, origem: "cnpj" },
    );
  } else if (validacoes.cnpj?.status === "REPROVADO") {
    ocorrencias.push({
      id: cnpjFailureId(validacoes.cnpj),
      comentario: cnpjFailureMessage(validacoes.cnpj),
      origem: "cnpj",
    });
  }

  if (validacoes.termo_quitacao?.status === "APROVADO") {
    ocorrencias.push({
      id: "C05",
      comentario: `TQ está no nome da seguradora ${seguradora} e assinado pelo segurado. OK, verificado.`,
      origem: "termo_quitacao",
      chave: "msgTQ",
    });
  } else if (validacoes.termo_quitacao?.status === "REPROVADO") {
    ocorrencias.push({
      id: termFailureId(validacoes.termo_quitacao),
      comentario: termFailureMessage(validacoes.termo_quitacao),
      origem: "termo_quitacao",
    });
  } else if (validacoes.termo_quitacao?.status === "PENDENTE") {
    ocorrencias.push({
      id: "C01",
      comentario: "Termo de quitacao encontrado, mas nao foi possivel extrair dados com IA.",
      origem: "termo_quitacao",
    });
  }

  const orcamento = validacoes.orcamento;
  const valoresOrcamento = orcamento?.dados?.orcamento || {};
  const dataOrcamento = valoresOrcamento.data_orcamento || dadosOrcamento?.dados?.dataOrcamento || "data nao informada";

  if (orcamento?.status === "APROVADO") {
    ocorrencias.push(
      {
        id: "C08",
        comentario: `Orçamento FINAL inserido pelo consultor em sistema confere com a última versão de orçamento disponível no portal ${seguradora}. OK, verificado.`,
        origem: "orcamento",
      },
      {
        id: "C10",
        comentario: `Valor total para faturar à Cia em Sistema, confere com a ultima versão do orçamento autorizado em ${dataOrcamento} e consulta efetuada no portal ${seguradora}.`,
        origem: "orcamento",
      },
      {
        id: "C11",
        comentario: `Autorização de emissão de nota fiscal para a seguradora ${seguradora}.`,
        origem: "orcamento",
      },
    );
  } else if (orcamento?.status === "REPROVADO") {
    addValueOccurrences(ocorrencias, orcamento);
  } else if (orcamento?.status === "PENDENTE") {
    ocorrencias.push({
      id: orcamento?.dados?.complemento?.manual ? "C25" : "C01",
      comentario: orcamento?.mensagem || "Valores do orçamento pendentes para batimento.",
      origem: "orcamento",
    });
  }

  addOperationalOccurrences(ocorrencias, statusConsolidacao, orcamento);

  if (mainValidationsApproved(validacoes)) {
    ocorrencias.push({
      id: "C12",
      comentario: "Processo finalizado com sucesso. Dados verificados. OK conferido.",
      origem: "finalizacao",
    });
  }

  return dedupeOccurrences(ocorrencias);
}

function addValueOccurrences(ocorrencias, orcamento) {
  const comparacoes = orcamento?.dados?.comparacoes || [];
  const total = comparacoes.find((comparacao) => comparacao.campo === "valor_total");
  const franquia = comparacoes.find((comparacao) => comparacao.campo === "valor_franquia");

  if (!total || !total.confere) {
    ocorrencias.push({
      id: "C23",
      comentario: valueDivergenceMessage(orcamento),
      origem: "valor_divergente",
    });
  }

  if (franquia && !franquia.confere) {
    ocorrencias.push({
      id: "C28",
      comentario: "Valor informado na Franquia está incorreta. Favor corrigir conforme orçamento aprovado no site da seguradora.",
      origem: "valor_franquia_divergente",
    });
  }
}

function addOperationalOccurrences(ocorrencias, statusConsolidacao, orcamento) {
  if (statusConsolidacao === "REPROVADA_VALOR_DIVERGENTE") {
    addValueOccurrences(ocorrencias, orcamento);
  }
  if (statusConsolidacao === "PENDENTE_COMPLEMENTO_MANUAL") {
    ocorrencias.push({
      id: "C25",
      comentario: "OS com complemento identificado no Conference. Fechamento deve ser realizado manualmente.",
      origem: "complemento",
    });
  }
  if (statusConsolidacao === "REPROVADA_CNPJ_INVALIDO") {
    ocorrencias.push({
      id: "C26",
      comentario: "CNPJ divergente ou inválido na validação. OS reprovada automaticamente.",
      origem: "cnpj",
    });
  }
}

function mainValidationsApproved(validacoes) {
  return ["anexos", "cnpj", "orcamento", "termo_quitacao"].every((key) => validacoes[key]?.status === "APROVADO");
}

function cnpjFailureId(validacao) {
  const mensagem = String(validacao?.mensagem || "").toLowerCase();
  return mensagem.includes("diverge") || mensagem.includes("nao confere") || mensagem.includes("não confere") ? "C17" : "C13";
}

function cnpjFailureMessage(validacao) {
  const mensagem = String(validacao?.mensagem || "").toLowerCase();
  if (mensagem.includes("diverge") || mensagem.includes("nao confere") || mensagem.includes("não confere")) {
    const cnpj = formatCnpj(validacao?.dados?.cnpj_correto);
    return `A NF deve ser faturada no CNPJ ${cnpj}. OS Reprovada, favor ajustar.`;
  }
  return "O CNPJ da seguradora está inativo ou inválido.";
}

function termFailureId(validacao) {
  const mensagem = String(validacao?.mensagem || "").toLowerCase();
  if (mensagem.includes("sem assinatura")) return "C04";
  if (mensagem.includes("seguradora")) return "C03";
  if (mensagem.includes("nao foi encontrado") || mensagem.includes("não foi encontrado")) return "C02";
  return "C01";
}

function termFailureMessage(validacao) {
  const mensagem = String(validacao?.mensagem || "");
  const lower = mensagem.toLowerCase();
  if (lower.includes("sem assinatura")) return "TQ não assinado. Favor corrigir.";
  if (lower.includes("seguradora")) return "TQ não confere. Nome da seguradora está incorreto.";
  if (lower.includes("nao foi encontrado") || lower.includes("não foi encontrado")) return "O arquivo TERMO DE QUITAÇÃO não foi encontrado.";
  return mensagem || "TQ não confere. Favor corrigir.";
}

function valueDivergenceMessage(orcamento) {
  const valorTotal = orcamento?.dados?.orcamento?.valor_total;
  if (valorTotal === null || valorTotal === undefined || valorTotal === "") {
    return "Orçamento FINAL inserido pelo consultor em sistema está com divergência de valores. Favor conferir.";
  }
  return "Orçamento FINAL inserido pelo consultor em sistema está com divergência de valores. Favor conferir.";
}

function dedupeOccurrences(ocorrencias) {
  const seen = new Set();
  return ocorrencias.filter((ocorrencia) => {
    const key = `${ocorrencia?.id || ""}:${ocorrencia?.comentario || ""}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function applyManualOccurrenceOverrides(generated, history) {
  const removedGenerated = new Set();
  const manualInserted = new Map();

  for (const entry of Array.isArray(history) ? history : []) {
    const ocorrencia = entry?.ocorrencia;
    if (!ocorrencia) continue;

    if (entry.acao === "INSERIR") {
      manualInserted.set(strictOccurrenceKey(ocorrencia), ocorrencia);
    }

    if (entry.acao === "REMOVER") {
      if (ocorrencia.origem === "curadoria_manual" && ocorrencia.criadoEm) {
        manualInserted.delete(strictOccurrenceKey(ocorrencia));
      } else {
        removedGenerated.add(looseOccurrenceKey(ocorrencia));
      }
    }
  }

  const keptGenerated = (Array.isArray(generated) ? generated : []).filter(
    (ocorrencia) => !removedGenerated.has(looseOccurrenceKey(ocorrencia)),
  );

  return dedupeOccurrences([...keptGenerated, ...manualInserted.values()]);
}

function strictOccurrenceKey(ocorrencia) {
  return `${looseOccurrenceKey(ocorrencia)}:${ocorrencia?.origem || ""}:${ocorrencia?.criadoEm || ""}`;
}

function looseOccurrenceKey(ocorrencia) {
  return `${ocorrencia?.id || ""}:${ocorrencia?.comentario || ""}`;
}

function classifyValidacoes(validacoes) {
  const statuses = {
    anexos: validacoes.anexos?.status,
    cnpj: validacoes.cnpj?.status,
    termo: validacoes.termo_quitacao?.status,
    orcamento: validacoes.orcamento?.status,
  };
  const values = Object.values(validacoes || {}).map((validacao) => validacao?.status);

  if (values.includes("ERRO")) {
    return { statusConsolidacao: "ERRO_TECNICO", acaoSugerida: "ENVIAR_PARA_BATIMENTO_HUMANO" };
  }
  if (statuses.anexos === "REPROVADO") {
    return { statusConsolidacao: "REPROVADA_FALTA_ANEXO", acaoSugerida: "RETORNAR_OFICINA" };
  }
  if (statuses.cnpj === "REPROVADO") {
    return { statusConsolidacao: "REPROVADA_CNPJ_INVALIDO", acaoSugerida: "FECHAR_MANUAL" };
  }
  if (statuses.termo === "REPROVADO") {
    return { statusConsolidacao: "REPROVADA_TERMO_INVALIDO", acaoSugerida: "RETORNAR_OFICINA" };
  }
  if (statuses.orcamento === "REPROVADO") {
    return { statusConsolidacao: "REPROVADA_VALOR_DIVERGENTE", acaoSugerida: "ENVIAR_PARA_BATIMENTO_HUMANO" };
  }
  if (values.includes("PENDENTE")) {
    return { statusConsolidacao: "PENDENTE_BATIMENTO_HUMANO", acaoSugerida: "RETORNAR_OFICINA" };
  }
  return { statusConsolidacao: "APROVADA_CONSOLIDACAO", acaoSugerida: "ENVIAR_PARA_FECHAMENTO" };
}

function formatCnpj(value) {
  const digits = String(value || "").replace(/\D/g, "");
  return digits.replace(/^(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})$/, "$1.$2.$3/$4-$5");
}
