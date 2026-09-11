#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://10.255.172.58:8000}"
LOG_DIR="${LOG_DIR:-/tmp/atri-rpa-cron}"
LOCK_FILE="${LOCK_FILE:-/tmp/atri-rpa-sync-bases.lock}"
CONNECT_TIMEOUT_SECONDS="${CONNECT_TIMEOUT_SECONDS:-20}"
MAX_TIME_SECONDS="${MAX_TIME_SECONDS:-900}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync_bases_$(date +%Y%m%d).log"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

request() {
  local method="$1"
  local path="$2"
  local output_file="$3"
  local status_file="${output_file}.status"

  curl \
    --silent \
    --show-error \
    --request "$method" \
    --connect-timeout "$CONNECT_TIMEOUT_SECONDS" \
    --max-time "$MAX_TIME_SECONDS" \
    --write-out '%{http_code}' \
    --output "$output_file" \
    "${API_BASE_URL}${path}" > "$status_file"
}

with_lock() {
  if command -v flock >/dev/null 2>&1; then
    flock -n 9 || {
      log "Outra sincronizacao ainda esta em execucao. Saindo."
      exit 0
    }
    "$@"
  else
    if ! mkdir "$LOCK_FILE" 2>/dev/null; then
      if [ -f "$LOCK_FILE/pid" ]; then
        old_pid="$(cat "$LOCK_FILE/pid" 2>/dev/null || true)"
        if [ -n "${old_pid:-}" ] && ! kill -0 "$old_pid" 2>/dev/null; then
          rmdir "$LOCK_FILE" 2>/dev/null || rm -rf "$LOCK_FILE"
          mkdir "$LOCK_FILE"
        else
          log "Outra sincronizacao ainda esta em execucao. Saindo."
          exit 0
        fi
      else
        rmdir "$LOCK_FILE" 2>/dev/null || rm -rf "$LOCK_FILE"
        mkdir "$LOCK_FILE"
      fi
    fi

    if [ -d "$LOCK_FILE" ]; then
      printf '%s\n' "$$" > "$LOCK_FILE/pid"
    else
      log "Outra sincronizacao ainda esta em execucao. Saindo."
      exit 0
    fi
    trap 'rm -rf "$LOCK_FILE"' EXIT
    "$@"
  fi
}

run_sync() {
  local health_body
  local health_status
  local full_body
  local full_status
  local rules_body
  local rules_status

  health_body="$(mktemp)"
  full_body="$(mktemp)"
  rules_body="$(mktemp)"

  log "Iniciando atualizacao de bases em ${API_BASE_URL}"

  request GET "/health/storage" "$health_body"
  health_status="$(cat "${health_body}.status")"
  log "Health storage HTTP ${health_status}: $(tr -d '\n' < "$health_body")"
  if [ "$health_status" != "200" ]; then
    log "Health storage falhou. Abortando sincronizacao."
    exit 1
  fi

  set +e
  request POST "/cadastros/sincronizar" "$full_body"
  full_exit=$?
  set -e
  full_status="$(cat "${full_body}.status" 2>/dev/null || printf '000')"

  if [ "$full_exit" -eq 0 ] && [ "$full_status" = "200" ]; then
    log "Sincronizacao completa OK: $(tr -d '\n' < "$full_body")"
    rm -f "$health_body" "$health_body.status" "$full_body" "$full_body.status" "$rules_body" "$rules_body.status"
    exit 0
  fi

  log "Sincronizacao completa falhou. curl_exit=${full_exit}, http=${full_status}, body=$(tr -d '\n' < "$full_body")"
  log "Executando fallback: sincronizacao de regras CNPJ."

  set +e
  request POST "/cadastros/regras-cnpj/sincronizar" "$rules_body"
  rules_exit=$?
  set -e
  rules_status="$(cat "${rules_body}.status" 2>/dev/null || printf '000')"
  log "Regras CNPJ HTTP ${rules_status}: $(tr -d '\n' < "$rules_body")"

  if [ "$rules_exit" -ne 0 ] || [ "$rules_status" != "200" ]; then
    log "Fallback de regras CNPJ falhou. curl_exit=${rules_exit}, http=${rules_status}"
    rm -f "$health_body" "$health_body.status" "$full_body" "$full_body.status" "$rules_body" "$rules_body.status"
    exit 1
  fi

  rm -f "$health_body" "$health_body.status" "$full_body" "$full_body.status" "$rules_body" "$rules_body.status"
}

if command -v flock >/dev/null 2>&1; then
  with_lock run_sync 9>"$LOCK_FILE"
else
  with_lock run_sync
fi
