import { NextResponse } from "next/server";
import { clearSessionCookieOptions, SESSION_COOKIE } from "../../../../lib/auth/session.js";

export const dynamic = "force-dynamic";
export const runtime = "nodejs";

export async function POST() {
  const response = NextResponse.json({ ok: true });
  response.cookies.set(SESSION_COOKIE, "", clearSessionCookieOptions());
  return response;
}
