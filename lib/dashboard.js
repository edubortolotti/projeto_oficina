export function normalizeJson(value) {
  if (!value) return {};
  if (typeof value === "string") {
    try {
      return JSON.parse(value);
    } catch {
      return {};
    }
  }
  return value;
}

export function toNumber(value) {
  if (value === null || value === undefined || value === "") return 0;
  if (typeof value === "object" && typeof value.toNumber === "function") {
    return value.toNumber();
  }
  const number = Number(value);
  return Number.isFinite(number) ? number : 0;
}

export function currency(value) {
  return Math.round(toNumber(value) * 100) / 100;
}

export function dateKey(date) {
  if (!date) return "sem-data";
  const parsed = new Date(date);
  if (Number.isNaN(parsed.getTime())) return "sem-data";
  return parsed.toISOString().slice(0, 10);
}

export function increment(map, key, amount = 1) {
  map[key] = (map[key] || 0) + amount;
}

export function sortObjectEntries(object) {
  return Object.entries(object)
    .map(([key, value]) => ({ key, value }))
    .sort((a, b) => String(a.key).localeCompare(String(b.key)));
}

export function statusLabel(status) {
  const labels = {
    APROVADA_CONSOLIDACAO: "Aprovada",
    FALHA_SINCRONIZACAO_NBS_FECHAR_MANUAL: "Valores",
    PENDENTE_BATIMENTO_HUMANO: "Pendente",
    PENDENTE_COMPLEMENTO_MANUAL: "Manual",
    REPROVADA_CNPJ_INVALIDO: "CNPJ",
    REPROVADA_FALTA_ANEXO: "Anexo",
    REPROVADA_TERMO_INVALIDO: "Termo",
    REPROVADA_VALOR_DIVERGENTE: "Valores",
    ERRO_TECNICO: "Erro",
  };

  return labels[status] || status || "Nao informado";
}

export function getConferenceValue(payload) {
  const dadosConference = normalizeJson(payload.dadosConference);
  const resultadoJson = normalizeJson(payload.resultadoJson);
  const resultadoConference = normalizeJson(resultadoJson.dados_conference);
  const financeiro = normalizeJson(resultadoJson.dados_extraidos)?.financeiro_conference || {};

  return currency(
    dadosConference.valor_total ||
      resultadoConference.valor_total ||
      financeiro.valor_total ||
      0
  );
}

export function getConferenceStatus(dadosConference) {
  const dados = normalizeJson(dadosConference);
  const raw = normalizeJson(dados.raw);
  return String(dados.status || raw.status || raw.status_codigo || raw.statusCode || "").trim();
}

export function isEncerradoManualmente(dadosConference) {
  const status = getConferenceStatus(dadosConference);
  return Boolean(status) && status !== "5";
}

export function safeError(error) {
  const message = String(error?.message || error || "Erro ao consultar dados.");
  if (message.includes("Authentication failed")) {
    return "Falha de autenticacao ao consultar o banco de dados.";
  }
  if (message.includes("Can't reach database") || message.includes("connect")) {
    return "Banco de dados indisponivel.";
  }
  return message.split("\n").filter(Boolean).slice(-1)[0]?.slice(0, 220) || "Erro ao consultar dados.";
}
