import { NextResponse } from "next/server";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "FORCAR_PROCESSAMENTO_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const response = await fetch(
      `${baseUrl}/processamento/${encodeURIComponent(os)}/forcar`,
      { method: "POST", cache: "no-store" },
    );
    const payload = await parseJsonResponse(response);

    if (!response.ok || payload.ok === false) {
      return NextResponse.json(
        {
          ok: false,
          error: payload.detail || payload.error || "Falha ao forcar o processamento da OS.",
          resultado: payload,
        },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json({ ok: true, os, resultado: payload });
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 500 });
  }
}

async function parseJsonResponse(response) {
  const text = await response.text();
  if (!text) return {};
  try {
    return JSON.parse(text);
  } catch {
    throw new Error(`Resposta invalida do processamento forcado. HTTP ${response.status}.`);
  }
}
