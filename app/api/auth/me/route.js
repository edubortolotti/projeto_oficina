import { NextResponse } from "next/server";
import { SESSION_COOKIE, verifySessionCookie } from "../../../../lib/auth/session.js";

export const dynamic = "force-dynamic";
export const runtime = "nodejs";

export async function GET(request) {
  const session = verifySessionCookie(request.cookies.get(SESSION_COOKIE)?.value);
  if (!session) {
    return NextResponse.json({ ok: false, user: null }, { status: 401 });
  }
  return NextResponse.json({
    ok: true,
    user: {
      id: Number(session.sub),
      nome: session.nome,
      login: session.login,
      perfil: session.perfil,
      adUsuario: Boolean(session.adUsuario),
    },
  });
}
