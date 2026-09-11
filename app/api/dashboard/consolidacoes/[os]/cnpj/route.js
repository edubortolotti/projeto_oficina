import { NextResponse } from "next/server";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "REVISAR_CNPJ_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const body = await request.json().catch(() => ({}));
    const aprovado = Boolean(body.aprovado);
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const response = await fetch(`${baseUrl}/dashboard/consolidacoes/${encodeURIComponent(os)}/cnpj`, {
      method: "POST",
      cache: "no-store",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(aprovado),
    });
    const payload = await parseJsonResponse(response, "Falha ao ler resposta da curadoria de CNPJ.");

    if (!response.ok || payload.detail || payload.ok === false) {
      return NextResponse.json(
        { ok: false, error: payload.detail || payload.error || "Falha ao revisar CNPJ.", os },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json(payload);
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
