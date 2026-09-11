import { NextResponse } from "next/server";
import { SESSION_COOKIE, verifySessionCookie } from "./session.js";

export const PERFIS = {
  ADMIN: "ADMIN",
  CURADOR: "CURADOR",
  OPERADOR: "OPERADOR",
  LEITURA: "LEITURA",
};

export const PERMISSIONS = {
  VIEW_DASHBOARD: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR, PERFIS.LEITURA],
  VIEW_CONSOLIDACOES: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR, PERFIS.LEITURA],
  VIEW_DETALHES_OS: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR, PERFIS.LEITURA],
  DOWNLOAD_DOCUMENTOS: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR],
  SYNC_CONFERENCE: [PERFIS.ADMIN, PERFIS.OPERADOR],
  RUN_PASSO_1: [PERFIS.ADMIN, PERFIS.OPERADOR],
  RUN_PASSO_2: [PERFIS.ADMIN, PERFIS.OPERADOR],
  APROVAR_OS: [PERFIS.ADMIN, PERFIS.CURADOR],
  RETORNAR_OS: [PERFIS.ADMIN, PERFIS.CURADOR],
  REVISAR_CNPJ_OS: [PERFIS.ADMIN, PERFIS.CURADOR],
  AJUSTAR_VALORES_OS: [PERFIS.ADMIN, PERFIS.CURADOR],
  REPROCESSAR_OS: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR],
  FORCAR_PROCESSAMENTO_OS: [PERFIS.ADMIN],
  VIEW_FECHAMENTOS: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR, PERFIS.LEITURA],
  CANCELAR_FECHAMENTO: [PERFIS.ADMIN, PERFIS.CURADOR],
  VOLTAR_FECHAMENTO_CONSOLIDACAO: [PERFIS.ADMIN, PERFIS.CURADOR],
  VIEW_EXECUCOES: [PERFIS.ADMIN, PERFIS.CURADOR, PERFIS.OPERADOR, PERFIS.LEITURA],
  VIEW_CNPJS: [PERFIS.ADMIN, PERFIS.CURADOR],
  MANAGE_CNPJS: [PERFIS.ADMIN, PERFIS.CURADOR],
  VIEW_PORTAIS: [PERFIS.ADMIN],
  MANAGE_PORTAIS: [PERFIS.ADMIN],
  VIEW_USUARIOS: [PERFIS.ADMIN],
  MANAGE_USUARIOS: [PERFIS.ADMIN],
};

export function getSessionFromRequest(request) {
  return verifySessionCookie(request.cookies.get(SESSION_COOKIE)?.value);
}

export function hasPermission(session, permission) {
  const perfil = normalizePerfil(session?.perfil);
  return Boolean(perfil && (PERMISSIONS[permission] || []).includes(perfil));
}

export function requirePermission(request, permission) {
  const session = getSessionFromRequest(request);
  if (!session) {
    return {
      ok: false,
      response: NextResponse.json({ ok: false, error: "Nao autenticado." }, { status: 401 }),
    };
  }
  if (!hasPermission(session, permission)) {
    return {
      ok: false,
      response: NextResponse.json({ ok: false, error: "Acesso nao autorizado para este perfil." }, { status: 403 }),
    };
  }
  return { ok: true, session };
}

export function normalizePerfil(value) {
  return String(value || "").trim().toUpperCase();
}
