import { NextResponse } from "next/server";
import { prisma } from "../../../../../../lib/prisma";
import { safeError } from "../../../../../../lib/dashboard";
import { requirePermission } from "../../../../../../lib/auth/permissions";

export const dynamic = "force-dynamic";

export async function POST(request, { params }) {
  const auth = requirePermission(request, "REPROCESSAR_OS");
  if (!auth.ok) return auth.response;

  try {
    const { os } = await params;
    const existing = await prisma.$queryRaw`
      SELECT os, dadosExtraidos
      FROM consolidacoes
      WHERE os = ${os}
      LIMIT 1
    `;
    if (!existing.length) {
      return NextResponse.json({ ok: false, error: "OS nao encontrada para reprocessamento.", os }, { status: 404 });
    }

    const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
    const dadosExtraidos = normalizeJson(existing[0].dadosExtraidos);
    const temAjusteManual = Boolean(Object.keys(dadosExtraidos.ajustes_manuais_atuais || {}).length);
    const params = new URLSearchParams({
      forcar: "true",
      reler_orcamento: temAjusteManual ? "false" : "true",
      reler_documentos: temAjusteManual ? "false" : "true",
    });
    const url = `${baseUrl}/passo1/consolidacao/${encodeURIComponent(os)}?${params}`;
    const response = await fetch(url, {
      method: "GET",
      cache: "no-store",
    });
    const payload = await parseJsonResponse(response, "Falha ao ler resposta da API do Passo 1.");

    if (!response.ok || payload.detail) {
      return NextResponse.json(
        { ok: false, error: payload.detail || "Falha ao reprocessar OS.", os },
        { status: response.status || 500 },
      );
    }

    return NextResponse.json({ ok: true, os, resultado: payload });
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

function normalizeJson(value) {
  if (!value) return {};
  if (typeof value === "object") return value;
  try {
    return JSON.parse(value);
  } catch {
    return {};
  }
}
