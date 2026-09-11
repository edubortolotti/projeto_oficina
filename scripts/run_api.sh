#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-8000}"
APP_MODULE="${APP_MODULE:-client:app}"

cd "$PROJECT_DIR"

git pull --ff-only

if [ -d ".venv" ]; then
  # shellcheck disable=SC1091
  . ".venv/bin/activate"
fi

python -m pip install -r requirements.txt
python -m uvicorn "$APP_MODULE" --host "$HOST" --port "$PORT"
