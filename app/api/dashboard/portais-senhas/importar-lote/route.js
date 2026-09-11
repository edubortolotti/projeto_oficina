import { NextResponse } from "next/server";
import { safeError } from "../../../../../lib/dashboard";
import { requirePermission } from "../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request) {
  const auth = requirePermission(request, "MANAGE_PORTAIS");
  if (!auth.ok) return auth.response;

  try {
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const payload = await request.json();
    const response = await fetch(`${baseUrl}/dashboard/portais-senhas/importar-lote`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
      cache: "no-store",
    });
    const result = await parseJsonResponse(response, "Falha ao importar logins e senhas.");

    if (!response.ok || result.detail || result.ok === false) {
      return NextResponse.json(
        {
          ok: false,
          error: result.detail || result.error || "Falha ao importar logins e senhas.",
        },
        { status: response.status || 400 },
      );
    }

    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
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
