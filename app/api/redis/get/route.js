import { NextResponse } from "next/server";
import { safeError } from "../../../../lib/dashboard";

export const dynamic = "force-dynamic";

export async function POST(request) {
  try {
    const payload = await request.json();
    validateGetPayload(payload);

    const result = await proxyRedisRequest("/redis/get", payload, "Falha ao ler chave no Redis.");
    return NextResponse.json(result);
  } catch (error) {
    return NextResponse.json({ ok: false, error: safeError(error) }, { status: 400 });
  }
}

function validateGetPayload(payload) {
  if (!payload || typeof payload !== "object") throw new Error("Informe um JSON valido.");
  if (typeof payload.key !== "string" || !payload.key.trim()) throw new Error("Informe key.");
}

async function proxyRedisRequest(path, payload, fallbackMessage) {
  const baseUrl = process.env.DASHBOARD_API_BASE_URL || "http://127.0.0.1:8000";
  const response = await fetch(`${baseUrl}${path}`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
    cache: "no-store",
  });
  const result = await parseJsonResponse(response, fallbackMessage);

  if (!response.ok || result.detail || result.ok === false) {
    throw new Error(result.detail || result.error || fallbackMessage);
  }

  return result;
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
