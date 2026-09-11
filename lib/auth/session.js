import crypto from "node:crypto";

export const SESSION_COOKIE = "atri_session";
const SESSION_TTL_SECONDS = 8 * 60 * 60;

export function createSessionCookie(user) {
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    sub: String(user.id),
    login: user.login,
    nome: user.nome,
    perfil: user.perfil,
    adUsuario: Boolean(user.adUsuario),
    iat: now,
    exp: now + SESSION_TTL_SECONDS,
  };
  return signSession(payload);
}

export function verifySessionCookie(value) {
  if (!value || typeof value !== "string") return null;
  const parts = value.split(".");
  if (parts.length !== 2) return null;
  const [payloadEncoded, signature] = parts;
  const expected = hmac(payloadEncoded);
  if (!timingSafeEqual(signature, expected)) return null;

  try {
    const payload = JSON.parse(Buffer.from(payloadEncoded, "base64url").toString("utf8"));
    if (!payload.exp || Number(payload.exp) < Math.floor(Date.now() / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

export function sessionCookieOptions() {
  return {
    httpOnly: true,
    sameSite: "lax",
    secure: sessionCookieSecure(),
    path: "/",
    maxAge: SESSION_TTL_SECONDS,
  };
}

export function clearSessionCookieOptions() {
  return {
    httpOnly: true,
    sameSite: "lax",
    secure: sessionCookieSecure(),
    path: "/",
    maxAge: 0,
  };
}

function signSession(payload) {
  const payloadEncoded = Buffer.from(JSON.stringify(payload)).toString("base64url");
  return `${payloadEncoded}.${hmac(payloadEncoded)}`;
}

function hmac(value) {
  return crypto.createHmac("sha256", sessionSecret()).update(value).digest("base64url");
}

function timingSafeEqual(a, b) {
  const left = Buffer.from(String(a));
  const right = Buffer.from(String(b));
  return left.length === right.length && crypto.timingSafeEqual(left, right);
}

function sessionSecret() {
  const secret = process.env.AUTH_SESSION_SECRET || process.env.PORTAL_CREDENTIALS_SECRET;
  if (secret && secret.length >= 32) return secret;
  if (process.env.NODE_ENV === "production") {
    throw new Error("Configure AUTH_SESSION_SECRET com pelo menos 32 caracteres.");
  }
  return "atri-rpa-dev-session-secret-change-before-production";
}

function sessionCookieSecure() {
  const configured = String(process.env.AUTH_COOKIE_SECURE || "").trim().toLowerCase();
  if (["1", "true", "yes", "sim"].includes(configured)) return true;
  if (["0", "false", "no", "nao", "não"].includes(configured)) return false;
  return process.env.NODE_ENV === "production";
}
