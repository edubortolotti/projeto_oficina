import { NextResponse } from "next/server";
import { safeError } from "../../../../lib/dashboard";
import { requirePermission } from "../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function GET(request) {
  const auth = requirePermission(request, "VIEW_CONSOLIDACOES");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const url = new URL(request.url);
    const limit = url.searchParams.get("limit") || "500";
    const params = new URLSearchParams({ limit });
    const response = await fetch(`${baseUrl}/dashboard/consolidacoes?${params}`, {
      method: "GET",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler dashboard de consolidacoes.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        {
          ok: false,
          error: payload.detail || payload.error || "Falha ao carregar consolidacoes.",
          ...emptyConsolidacoes(),
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
        ...emptyConsolidacoes(),
      },
      { status: 500 },
    );
  }
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

function emptyConsolidacoes() {
  return {
    totals: {
      total: 0,
      aprovadas: 0,
      pendentes: 0,
      reprovadas: 0,
      erros: 0,
      naoAnalisadas: 0,
      curadorAprovadas: 0,
      aguardandoCuradoria: 0,
      automaticos: 0,
      valorTotal: 0,
      aprovadoValor: 0,
      pendenteValor: 0,
    },
    timeline: [],
    byStatus: [],
    byAction: [],
    bySeguradora: [],
    byValidation: [],
    items: [],
  };
}
