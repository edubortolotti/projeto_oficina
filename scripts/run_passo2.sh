#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://10.255.172.58:8000}"
LOG_DIR="${LOG_DIR:-/tmp/atri-rpa-cron}"
LOCK_FILE="${LOCK_FILE:-/tmp/atri-rpa-passo2.lock}"
CONNECT_TIMEOUT_SECONDS="${CONNECT_TIMEOUT_SECONDS:-20}"
MAX_TIME_SECONDS="${MAX_TIME_SECONDS:-900}"
LIMIT="${LIMIT:-100}"
DRY_RUN="${DRY_RUN:-false}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/passo2_$(date +%Y%m%d).log"

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
      log "Outra execucao do Passo 2 ainda esta em andamento. Saindo."
      exit 0
    }
    "$@"
  else
    if ! mkdir "$LOCK_FILE" 2>/dev/null; then
      log "Outra execucao do Passo 2 ainda esta em andamento. Saindo."
      exit 0
    fi
    trap 'rm -rf "$LOCK_FILE"' EXIT
    "$@"
  fi
}

run_passo2() {
  local body
  local status
  local query

  body="$(mktemp)"
  query="limit=${LIMIT}&dry_run=${DRY_RUN}"

  log "Executando Passo 2 em ${API_BASE_URL}"
  request POST "/passo2/curadoria-automatica?${query}" "$body"
  status="$(cat "${body}.status")"
  log "Resposta HTTP ${status}: $(tr -d '\n' < "$body")"

  rm -f "$body" "$body.status"

  if [ "$status" != "200" ]; then
    exit 1
  fi

  log "Passo 2 concluido."
}

if command -v flock >/dev/null 2>&1; then
  with_lock run_passo2 9>"$LOCK_FILE"
else
  with_lock run_passo2
fi
