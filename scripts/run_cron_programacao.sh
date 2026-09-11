#!/usr/bin/env bash
set -euo pipefail

JOB="${1:-}"
PROJECT_DIR="${PROJECT_DIR:-/home/suporte/rpa}"
API_BASE_URL="${API_BASE_URL:-http://10.255.172.58:8000}"
LOG_DIR="${LOG_DIR:-${PROJECT_DIR}/logs/cron}"
LOCK_FILE="${LOCK_FILE:-/tmp/atri-rpa-programacao.lock}"

mkdir -p "$LOG_DIR"

case "$JOB" in
  sync_bases)
    LOG_FILE="$LOG_DIR/sync_bases_cron.out"
    ;;
  passo1)
    LOG_FILE="$LOG_DIR/passo1_cron.out"
    ;;
  passo2)
    LOG_FILE="$LOG_DIR/passo2_cron.out"
    ;;
  passo3)
    LOG_FILE="$LOG_DIR/passo3_cron.out"
    ;;
  *)
    printf 'Uso: %s {sync_bases|passo1|passo2|passo3}\n' "$0" >&2
    exit 2
    ;;
esac

exec >> "$LOG_FILE" 2>&1

cd "$PROJECT_DIR"

export API_BASE_URL
export LOG_DIR
export LOCK_FILE

case "$JOB" in
  sync_bases)
    bash scripts/sync_bases_cron.sh
    ;;
  passo1)
    export TIPO_DATA="${TIPO_DATA:-1}"
    export STATUS_CONFERENCE="${STATUS_CONFERENCE:-5}"
    bash scripts/run_passo1.sh
    ;;
  passo2)
    export LIMIT="${LIMIT:-100}"
    export DRY_RUN="${DRY_RUN:-false}"
    bash scripts/run_passo2.sh
    ;;
  passo3)
    export LIMIT="${LIMIT:-100}"
    export DRY_RUN="${DRY_RUN:-false}"
    bash scripts/run_passo3_job.sh
    ;;
esac
