import { NextResponse } from "next/server";
import { safeError } from "../../../../../lib/dashboard";
import { requirePermission } from "../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request) {
  const auth = requirePermission(request, "SYNC_CONFERENCE");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const params = new URLSearchParams({
      tipo_data: "1",
    });
    const response = await fetch(`${baseUrl}/dashboard/consolidacoes/sincronizar-conference?${params}`, {
      method: "POST",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler resposta da sincronizacao Conference.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        { ok: false, error: payload.detail || payload.error || "Falha ao sincronizar Conference." },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json({
      ok: true,
      resultado: payload,
    });
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
