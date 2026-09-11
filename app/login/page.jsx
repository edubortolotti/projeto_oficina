"use client";

import { LockKeyhole, LogIn } from "lucide-react";
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";

export default function LoginPage() {
  return (
    <Suspense fallback={<main className="loginShell" />}>
      <LoginForm />
    </Suspense>
  );
}

function LoginForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [login, setLogin] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  async function submit(event) {
    event.preventDefault();
    setLoading(true);
    setError("");
    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        cache: "no-store",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ login, password }),
      });
      const payload = await response.json().catch(() => ({}));
      if (!response.ok || payload.ok === false) {
        throw new Error(payload.error || "Falha ao autenticar.");
      }
      router.replace(searchParams.get("next") || "/");
      router.refresh();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="loginShell">
      <form className="loginPanel" onSubmit={submit}>
        <div className="loginIcon">
          <LockKeyhole size={24} />
        </div>
        <div>
          <p className="eyebrow">ATRI RPA</p>
          <h1>Acesso</h1>
        </div>

        <label className="formField">
          <span>Usuário</span>
          <input
            autoComplete="username"
            autoFocus
            onChange={(event) => setLogin(event.target.value)}
            placeholder="usuario ou DOMINIO\\usuario"
            value={login}
          />
        </label>

        <label className="formField">
          <span>Senha</span>
          <input
            autoComplete="current-password"
            onChange={(event) => setPassword(event.target.value)}
            type="password"
            value={password}
          />
        </label>

        {error ? <div className="loginError">{error}</div> : null}

        <button className="loginButton" disabled={loading || !login.trim() || !password} type="submit">
          <LogIn size={18} />
          {loading ? "Entrando" : "Entrar"}
        </button>
      </form>
    </main>
  );
}
