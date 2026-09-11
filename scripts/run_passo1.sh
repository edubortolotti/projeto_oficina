#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000}"
LOG_DIR="${LOG_DIR:-/tmp/atri-rpa-cron}"
LOCK_FILE="${LOCK_FILE:-/tmp/atri-rpa-passo1.lock}"
CONNECT_TIMEOUT_SECONDS="${CONNECT_TIMEOUT_SECONDS:-20}"
MAX_TIME_SECONDS="${MAX_TIME_SECONDS:-3600}"
TIPO_DATA="${TIPO_DATA:-1}"
STATUS_CONFERENCE="${STATUS_CONFERENCE:-5}"

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/passo1_$(date +%Y%m%d).log"

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
      log "Outra execucao do Passo 1 ainda esta em andamento. Saindo."
      exit 0
    }
    "$@"
  else
    if ! mkdir "$LOCK_FILE" 2>/dev/null; then
      log "Outra execucao do Passo 1 ainda esta em andamento. Saindo."
      exit 0
    fi
    trap 'rm -rf "$LOCK_FILE"' EXIT
    "$@"
  fi
}

build_query() {
  local query="tipo_data=${TIPO_DATA}&status=${STATUS_CONFERENCE}&reler_orcamento=true&reler_documentos=true"
  printf '%s' "$query"
}

run_passo1() {
  local body
  local status
  local query

  body="$(mktemp)"
  query="$(build_query)"

  log "Executando Passo 1 em ${API_BASE_URL}"
  request POST "/passo1/consolidacao/executar?${query}" "$body"
  status="$(cat "${body}.status")"
  log "Resposta HTTP ${status}: $(tr -d '\n' < "$body")"

  if [ "$status" != "200" ]; then
    rm -f "$body" "$body.status"
    exit 1
  fi

  rm -f "$body" "$body.status"
  log "Passo 1 concluido."
}

if command -v flock >/dev/null 2>&1; then
  with_lock run_passo1 9>"$LOCK_FILE"
else
  with_lock run_passo1
fi
