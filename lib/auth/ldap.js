import { Client } from "ldapts";
import { usernameFromLogin } from "./users.js";

export async function authenticateLdap(login, password) {
  if (!password) throw new Error("Senha obrigatoria.");

  const config = ldapConfig();
  const client = new Client({
    url: config.url,
    timeout: config.timeout,
    connectTimeout: config.timeout,
    tlsOptions: config.useSsl ? { rejectUnauthorized: config.rejectUnauthorized } : undefined,
  });

  try {
    if (config.bindUser && config.bindPassword) {
      await client.bind(config.bindUser, config.bindPassword);
      const user = await findLdapUser(client, config, login);
      if (!user?.dn) throw new Error("Usuario nao encontrado no LDAP.");
      await client.bind(user.dn, password);
      return user;
    }

    await client.bind(bindPrincipal(config, login), password);
    return { dn: bindPrincipal(config, login), sAMAccountName: usernameFromLogin(login) };
  } finally {
    await client.unbind().catch(() => {});
  }
}

async function findLdapUser(client, config, login) {
  const username = usernameFromLogin(login);
  const filter = config.userFilter.replaceAll("{username}", escapeFilterValue(username));
  const { searchEntries } = await client.search(config.baseDn, {
    scope: "sub",
    filter,
    attributes: ["dn", "cn", "mail", "sAMAccountName", "userPrincipalName", "displayName"],
    sizeLimit: 1,
  });
  return searchEntries[0] || null;
}

function bindPrincipal(config, login) {
  const raw = String(login || "").trim();
  if (raw.includes("\\") || raw.includes("@")) return raw;
  if (config.netbiosDomain) return `${config.netbiosDomain}\\${raw}`;
  if (config.fqdn) return `${raw}@${config.fqdn}`;
  return raw;
}

function ldapConfig() {
  const host = ldapHost();
  const useSsl = truthy(process.env.AD_API_USE_SSL);
  const port = Number(useSsl ? process.env.AD_API_PORT_SSL || 636 : process.env.AD_API_PORT || 389);
  const protocol = useSsl ? "ldaps" : "ldap";
  const baseDn = String(process.env.AD_API_BASE_DN || "").trim();
  if (!host) throw new Error("Configure AD_API_BASE_URL com o servidor LDAP/Domain Controller.");
  if (!baseDn) throw new Error("Configure AD_API_BASE_DN.");

  return {
    host,
    port,
    useSsl,
    url: `${protocol}://${host}:${port}`,
    baseDn,
    fqdn: String(process.env.AD_API_FQDN || "").trim(),
    netbiosDomain: String(process.env.AD_API_NETBIOS_DOMAIN || process.env.AD_API_DOMAIN || "").trim(),
    bindUser: String(process.env.AD_API_USERNAME || "").trim(),
    bindPassword: String(process.env.AD_API_PASSWORD || ""),
    userFilter: String(process.env.AD_API_USER_FILTER || "(&(objectClass=user)(sAMAccountName={username}))"),
    rejectUnauthorized: process.env.AD_API_REJECT_UNAUTHORIZED !== "false",
    timeout: Number(process.env.AD_API_TIMEOUT_MS || 8000),
  };
}

function ldapHost() {
  const raw = unquoteEnvValue(process.env.AD_API_BASE_URL);
  if (!raw) return "";
  try {
    const parsed = new URL(raw.includes("://") ? raw : `ldap://${raw}`);
    return parsed.hostname || raw;
  } catch {
    return raw.replace(/^ldaps?:\/\//, "").split("/")[0].split(":")[0];
  }
}

function unquoteEnvValue(value) {
  const raw = String(value || "").trim();
  const first = raw[0];
  const last = raw[raw.length - 1];
  if ((first === "\"" && last === "\"") || (first === "'" && last === "'")) {
    return raw.slice(1, -1).trim();
  }
  return raw;
}

function truthy(value) {
  return ["1", "true", "yes", "sim"].includes(String(value || "").toLowerCase());
}

function escapeFilterValue(value) {
  return String(value || "")
    .replaceAll("\\", "\\5c")
    .replaceAll("*", "\\2a")
    .replaceAll("(", "\\28")
    .replaceAll(")", "\\29")
    .replaceAll("\u0000", "\\00");
}
