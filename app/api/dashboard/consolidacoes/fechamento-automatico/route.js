import { NextResponse } from "next/server";
import { safeError } from "../../../../../lib/dashboard";
import { requirePermission } from "../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request) {
  const auth = requirePermission(request, "RUN_PASSO_2");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const params = new URLSearchParams({
      limit: "100",
      dry_run: "false",
    });
    const response = await fetch(`${baseUrl}/passo2/curadoria-automatica?${params}`, {
      method: "POST",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler resposta do fechamento automático.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        { ok: false, error: payload.detail || payload.error || "Falha ao aprovar/reprovar automaticamente." },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json({ ok: true, resultado: payload });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
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
