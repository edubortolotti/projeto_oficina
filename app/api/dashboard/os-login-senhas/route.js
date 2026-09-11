import { NextResponse } from "next/server";
import { safeError } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const url = new URL(request.url);
    const params = new URLSearchParams();

    copyParam(url.searchParams, params, "limit");
    copyParam(url.searchParams, params, "seguradora");
    copyParam(url.searchParams, params, "empresa");
    copyParam(url.searchParams, params, "incluir_senha");
    copyParamAs(url.searchParams, params, "incluirSenha", "incluir_senha");

    const response = await fetch(`${baseUrl}/dashboard/os-login-senhas?${params}`, {
      method: "GET",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler OSs com logins e senhas.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        {
          ok: false,
          error: payload.detail || payload.error || "Falha ao carregar OSs com logins e senhas.",
          ...emptyResponse(),
        },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json(payload);
  } catch (error) {
    return NextResponse.json(
      {
        ok: false,
        error: safeError(error),
        ...emptyResponse(),
      },
      { status: 500 },
    );
  }
}

function copyParam(source, target, name) {
  const value = source.get(name);
  if (value !== null && value !== "") target.set(name, value);
}

function copyParamAs(source, target, sourceName, targetName) {
  const value = source.get(sourceName);
  if (value !== null && value !== "" && !target.has(targetName)) target.set(targetName, value);
}

async function parseJsonResponse(response, fallbackMessage) {
  const text = await response.text();
  if (!text) return {};

  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`${fallbackMessage} HTTP ${response.status}: ${textPreview(text)}`);
  }
}

function textPreview(text) {
  return String(text)
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 220) || "resposta vazia ou invalida";
}

function emptyResponse() {
  return {
    totals: {
      total: 0,
      comCredenciais: 0,
      semCredenciais: 0,
      credenciais: 0,
    },
    bySeguradora: [],
    byEmpresa: [],
    items: [],
  };
}
