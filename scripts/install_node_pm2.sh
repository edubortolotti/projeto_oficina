#!/usr/bin/env bash
set -euo pipefail

NODE_MAJOR="${NODE_MAJOR:-22}"
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
APP_NAME="${APP_NAME:-atri-rpa-web}"
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-3000}"
ENV_FILE="${ENV_FILE:-$PROJECT_DIR/.env}"
SETUP_PM2_STARTUP="${SETUP_PM2_STARTUP:-1}"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_node_debian() {
  log "Instalando Node.js ${NODE_MAJOR}.x via NodeSource"
  run_sudo apt-get update
  run_sudo apt-get install -y ca-certificates curl gnupg
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | run_sudo bash -
  run_sudo apt-get install -y nodejs
}

install_node_rhel() {
  log "Instalando Node.js ${NODE_MAJOR}.x via NodeSource"
  curl -fsSL "https://rpm.nodesource.com/setup_${NODE_MAJOR}.x" | run_sudo bash -

  if command -v dnf >/dev/null 2>&1; then
    run_sudo dnf install -y nodejs
  else
    run_sudo yum install -y nodejs
  fi
}

install_node_alpine() {
  log "Instalando Node.js e npm via apk"
  run_sudo apk add --no-cache nodejs npm
}

install_node_macos() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew nao encontrado. Instale Node.js ${NODE_MAJOR}.x manualmente ou instale o Homebrew."
    exit 1
  fi

  log "Instalando Node.js via Homebrew"
  brew install "node@${NODE_MAJOR}" || brew upgrade "node@${NODE_MAJOR}" || true
  brew link --overwrite --force "node@${NODE_MAJOR}" || true
}

node_major_installed() {
  if ! command -v node >/dev/null 2>&1; then
    return 1
  fi

  current="$(node -p "process.versions.node.split('.')[0]")"
  [ "$current" = "$NODE_MAJOR" ]
}

install_node() {
  if node_major_installed; then
    log "Node.js $(node --version) ja esta instalado"
    return
  fi

  if command -v apt-get >/dev/null 2>&1; then
    install_node_debian
    return
  fi

  if command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
    install_node_rhel
    return
  fi

  if command -v apk >/dev/null 2>&1; then
    install_node_alpine
    return
  fi

  if [ "$(uname -s)" = "Darwin" ]; then
    install_node_macos
    return
  fi

  log "Sistema operacional nao suportado para instalacao automatica do Node.js."
  exit 1
}

install_pm2() {
  if command -v pm2 >/dev/null 2>&1; then
    log "PM2 $(pm2 --version) ja esta instalado"
    return
  fi

  log "Instalando PM2 globalmente"
  run_sudo npm install -g pm2
}

install_dependencies() {
  cd "$PROJECT_DIR"

  if [ ! -f package-lock.json ]; then
    log "package-lock.json nao encontrado em $PROJECT_DIR"
    exit 1
  fi

  log "Instalando dependencias Node com npm ci"
  npm ci
}

build_app() {
  cd "$PROJECT_DIR"

  log "Gerando Prisma Client"
  npm run prisma:generate

  log "Gerando build de producao do Next.js"
  npm run build
}

load_env_file() {
  if [ ! -f "$ENV_FILE" ]; then
    log "Arquivo de ambiente nao encontrado em $ENV_FILE. Continuando com variaveis atuais."
    return
  fi

  log "Carregando variaveis de ambiente de $ENV_FILE"
  set -a
  # shellcheck disable=SC1090
  . "$ENV_FILE"
  set +a
}

start_pm2() {
  cd "$PROJECT_DIR"
  export HOSTNAME="$HOST"
  export PORT
  export NODE_ENV=production
  export NEXT_TELEMETRY_DISABLED=1

  log "Subindo dashboard com PM2 em ${HOST}:${PORT}"
  if pm2 describe "$APP_NAME" >/dev/null 2>&1; then
    pm2 delete "$APP_NAME"
  fi

  pm2 start npm \
    --name "$APP_NAME" \
    --cwd "$PROJECT_DIR" \
    -- start -- -H "$HOST" -p "$PORT"

  pm2 save
}

setup_pm2_startup() {
  if [ "$SETUP_PM2_STARTUP" != "1" ]; then
    log "Setup de startup do PM2 ignorado porque SETUP_PM2_STARTUP=${SETUP_PM2_STARTUP}"
    return
  fi

  if [ "$(uname -s)" != "Linux" ]; then
    log "Startup automatico do PM2 e suportado automaticamente apenas em Linux neste script."
    return
  fi

  log "Configurando PM2 para iniciar com o sistema"
  startup_cmd="$(pm2 startup systemd -u "$(whoami)" --hp "$HOME" | awk '/sudo env PATH=/{print}')"
  if [ -n "$startup_cmd" ]; then
    eval "$startup_cmd"
  else
    log "Nao foi possivel extrair o comando de startup do PM2. Execute manualmente: pm2 startup"
  fi
}

main() {
  install_node
  log "Node: $(node --version)"
  log "npm: $(npm --version)"

  install_pm2
  install_dependencies
  build_app
  load_env_file
  start_pm2
  setup_pm2_startup

  log "Instalacao concluida"
  printf 'Dashboard: http://%s:%s\n' "$HOST" "$PORT"
  printf 'Status: pm2 status %s\n' "$APP_NAME"
  printf 'Logs: pm2 logs %s\n' "$APP_NAME"
}

main "$@"
