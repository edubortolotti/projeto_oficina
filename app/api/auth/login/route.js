import { NextResponse } from "next/server";
import { authenticateLdap } from "../../../../lib/auth/ldap.js";
import { createSessionCookie, sessionCookieOptions, SESSION_COOKIE } from "../../../../lib/auth/session.js";
import { findUserForLogin, verifyLocalPassword } from "../../../../lib/auth/users.js";

export const dynamic = "force-dynamic";
export const runtime = "nodejs";

export async function POST(request) {
  try {
    const payload = await request.json();
    const login = String(payload.login || "").trim();
    const password = String(payload.password || "");
    if (!login || !password) {
      return unauthorized("Informe usuario e senha.");
    }

    const user = await findUserForLogin(login);
    if (!user || !user.ativo) {
      return unauthorized("Usuario nao cadastrado ou inativo.");
    }

    if (loginByTokenEnabled()) {
      if (!verifyLoginToken(password)) {
        return unauthorized("Token de acesso invalido.");
      }
    } else if (user.adUsuario) {
      await authenticateLdap(login, password);
    } else if (!verifyLocalPassword(password, user)) {
      return unauthorized("Usuario ou senha invalidos.");
    }

    const response = NextResponse.json({ ok: true, user: publicUser(user) });
    response.cookies.set(SESSION_COOKIE, createSessionCookie(user), sessionCookieOptions());
    return response;
  } catch (error) {
    return NextResponse.json({ ok: false, error: loginError(error) }, { status: 401 });
  }
}

function unauthorized(error) {
  return NextResponse.json({ ok: false, error }, { status: 401 });
}

function loginByTokenEnabled() {
  return Boolean(String(process.env.LOGIN_BY_TOKEN || "").trim());
}

function verifyLoginToken(value) {
  return String(value || "") === String(process.env.LOGIN_BY_TOKEN || "");
}

function loginError(error) {
  const message = String(error?.message || error || "").toLowerCase();
  const code = String(error?.code || "").toUpperCase();

  if (message.includes("unable to verify the first certificate") || code === "UNABLE_TO_VERIFY_LEAF_SIGNATURE") {
    return "Nao foi possivel validar o certificado do servidor LDAP. Configure a cadeia de certificados ou use AD_API_REJECT_UNAUTHORIZED=false temporariamente.";
  }
  if (message.includes("self-signed certificate") || code === "DEPTH_ZERO_SELF_SIGNED_CERT") {
    return "O certificado do servidor LDAP e autoassinado. Configure a cadeia de certificados ou use AD_API_REJECT_UNAUTHORIZED=false temporariamente.";
  }
  if (message.includes("getaddrinfo") || code === "EAI_AGAIN" || code === "ENOTFOUND") {
    return "Nao foi possivel resolver o endereco do servidor LDAP. Verifique DNS ou AD_API_BASE_URL.";
  }
  if (message.includes("econnrefused") || code === "ECONNREFUSED") {
    return "Conexao recusada pelo servidor LDAP. Verifique host, porta e firewall.";
  }
  if (message.includes("etimedout") || message.includes("timeout") || code === "ETIMEDOUT") {
    return "Tempo esgotado ao conectar no servidor LDAP. Verifique rede, VPN, porta e firewall.";
  }
  if (message.includes("invalid credentials") || message.includes("data 52e")) {
    return "Usuario ou senha invalidos.";
  }
  if (message.includes("usuario nao encontrado")) {
    return "Usuario nao encontrado no LDAP.";
  }
  if (message.includes("senha obrigatoria")) {
    return "Senha obrigatoria.";
  }

  return "Nao foi possivel autenticar no LDAP. Verifique usuario, senha e configuracao do AD.";
}

function publicUser(user) {
  return {
    id: user.id,
    nome: user.nome,
    email: user.email,
    login: user.login,
    perfil: user.perfil,
    adUsuario: user.adUsuario,
    dominio: user.dominio,
  };
}
