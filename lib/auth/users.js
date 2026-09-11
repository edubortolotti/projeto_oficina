import crypto from "node:crypto";
import { Prisma } from "@prisma/client";
import { prisma } from "../prisma.js";

export async function ensureUsersSchema() {
  await prisma.$executeRaw`
    CREATE TABLE IF NOT EXISTS sistema_usuarios (
      id INT NOT NULL AUTO_INCREMENT,
      nome VARCHAR(160) NOT NULL,
      email VARCHAR(180) NULL,
      login VARCHAR(120) NOT NULL,
      perfil VARCHAR(40) NOT NULL DEFAULT 'OPERADOR',
      adUsuario TINYINT(1) NOT NULL DEFAULT 0,
      dominio VARCHAR(120) NULL,
      senhaHash VARCHAR(255) NULL,
      senhaSalt VARCHAR(64) NULL,
      ativo TINYINT(1) NOT NULL DEFAULT 1,
      criadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      atualizadoEm DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY sistema_usuarios_login_key (login),
      KEY sistema_usuarios_perfil_idx (perfil),
      KEY sistema_usuarios_adUsuario_idx (adUsuario)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `;
}

export async function findUserForLogin(login) {
  await ensureUsersSchema();
  const candidates = loginCandidates(login);
  if (!candidates.length) return null;

  const rows = await prisma.$queryRaw`
    SELECT id, nome, email, login, perfil, adUsuario, dominio, ativo, senhaHash, senhaSalt
    FROM sistema_usuarios
    WHERE login IN (${Prisma.join(candidates)})
    ORDER BY FIELD(login, ${Prisma.join(candidates)})
    LIMIT 1
  `;
  return rows[0] ? normalizeUser(rows[0]) : null;
}

export function verifyLocalPassword(password, user) {
  if (!user?.senhaHash || !user?.senhaSalt || !password) return false;
  const hash = crypto.pbkdf2Sync(String(password), user.senhaSalt, 120000, 32, "sha256").toString("hex");
  return timingSafeEqual(hash, user.senhaHash);
}

export function normalizeLogin(value) {
  return String(value || "").trim().toLowerCase();
}

export function loginCandidates(value) {
  const login = normalizeLogin(value);
  if (!login) return [];

  const netbios = normalizeLogin(process.env.AD_API_NETBIOS_DOMAIN);
  const fqdn = normalizeLogin(process.env.AD_API_FQDN);
  const domain = normalizeLogin(process.env.AD_API_DOMAIN);
  const candidates = [login];

  const username = usernameFromLogin(login);
  if (username && username !== login) candidates.push(username);
  if (username && netbios) candidates.push(`${netbios}\\${username}`);
  if (username && domain) candidates.push(`${domain}\\${username}`);
  if (username && fqdn) candidates.push(`${username}@${fqdn}`);

  return [...new Set(candidates.filter(Boolean))].slice(0, 8);
}

export function usernameFromLogin(value) {
  const login = normalizeLogin(value);
  if (!login) return "";
  if (login.includes("\\")) return login.split("\\").pop();
  if (login.includes("@")) return login.split("@")[0];
  return login;
}

export function normalizeUser(row) {
  return {
    id: Number(row.id),
    nome: row.nome || "",
    email: row.email || "",
    login: row.login || "",
    perfil: row.perfil || "OPERADOR",
    adUsuario: Boolean(row.adUsuario),
    dominio: row.dominio || "",
    ativo: Boolean(row.ativo),
    senhaHash: row.senhaHash || "",
    senhaSalt: row.senhaSalt || "",
  };
}

function timingSafeEqual(a, b) {
  const left = Buffer.from(String(a));
  const right = Buffer.from(String(b));
  return left.length === right.length && crypto.timingSafeEqual(left, right);
}
