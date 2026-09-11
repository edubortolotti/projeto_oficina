#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_DIR/docker-compose.prod.yml}"
ENV_FILE="${ENV_FILE:-$PROJECT_DIR/.env.docker}"
SOURCE_ENV_FILE="${SOURCE_ENV_FILE:-$PROJECT_DIR/.env}"
API_IMAGE="${ATRI_API_IMAGE:-atri-rpa-api:latest}"
WEB_IMAGE="${ATRI_WEB_IMAGE:-atri-rpa-web:latest}"
PROJECT_NAME="${COMPOSE_PROJECT_NAME:-atri-rpa}"
START_SERVICES="${START_SERVICES:-api web}"
PULL_IMAGES="${PULL_IMAGES:-0}"
SHOW_LOGS="${SHOW_LOGS:-0}"
HEALTHCHECK="${HEALTHCHECK:-1}"
API_HEALTH_URL="${API_HEALTH_URL:-http://localhost:8000/health}"
WEB_HEALTH_URL="${WEB_HEALTH_URL:-http://localhost:3000}"

log() {
  printf '\n[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1 && sudo docker info >/dev/null 2>&1; then
    sudo docker "$@"
    return
  fi

  fail "Docker nao esta disponivel para este usuario. Instale o Docker ou adicione o usuario ao grupo docker."
}

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
    return
  fi

  if command -v sudo >/dev/null 2>&1 && sudo docker compose version >/dev/null 2>&1; then
    sudo docker compose "$@"
    return
  fi

  fail "Docker Compose plugin nao esta disponivel. Instale docker-compose-plugin."
}

prepare_env() {
  if [ -f "$ENV_FILE" ]; then
    log "Usando arquivo de ambiente $ENV_FILE"
    return
  fi

  if [ -f "$SOURCE_ENV_FILE" ]; then
    log "Criando $ENV_FILE a partir de $SOURCE_ENV_FILE"
    cp "$SOURCE_ENV_FILE" "$ENV_FILE"
    return
  fi

  fail "Arquivo $ENV_FILE nao encontrado. Crie-o antes do deploy."
}

validate_files() {
  [ -f "$COMPOSE_FILE" ] || fail "Compose nao encontrado: $COMPOSE_FILE"
  prepare_env
}

validate_images() {
  if [ "$PULL_IMAGES" = "1" ]; then
    log "Puxando imagens configuradas"
    ATRI_API_IMAGE="$API_IMAGE" ATRI_WEB_IMAGE="$WEB_IMAGE" \
      compose_cmd --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" pull
    return
  fi

  docker_cmd image inspect "$API_IMAGE" >/dev/null 2>&1 || fail "Imagem API nao encontrada: $API_IMAGE. Rode scripts/build_docker_images.sh antes."
  docker_cmd image inspect "$WEB_IMAGE" >/dev/null 2>&1 || fail "Imagem WEB nao encontrada: $WEB_IMAGE. Rode scripts/build_docker_images.sh antes."
}

deploy() {
  log "Subindo containers Docker"
  log "Compose: $COMPOSE_FILE"
  log "Projeto Compose: $PROJECT_NAME"
  log "Imagem API: $API_IMAGE"
  log "Imagem WEB: $WEB_IMAGE"

  ATRI_API_IMAGE="$API_IMAGE" ATRI_WEB_IMAGE="$WEB_IMAGE" \
    compose_cmd --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d $START_SERVICES

  ATRI_API_IMAGE="$API_IMAGE" ATRI_WEB_IMAGE="$WEB_IMAGE" \
    compose_cmd --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps
}

healthcheck() {
  if [ "$HEALTHCHECK" != "1" ]; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    log "curl nao encontrado. Pulando healthcheck HTTP."
    return
  fi

  log "Validando API em $API_HEALTH_URL"
  curl --fail --silent --show-error --max-time 10 "$API_HEALTH_URL"
  printf '\n'

  log "Validando WEB em $WEB_HEALTH_URL"
  curl --fail --silent --show-error --max-time 10 "$WEB_HEALTH_URL" >/dev/null
  log "WEB respondeu com sucesso"
}

show_logs() {
  if [ "$SHOW_LOGS" != "1" ]; then
    return
  fi

  ATRI_API_IMAGE="$API_IMAGE" ATRI_WEB_IMAGE="$WEB_IMAGE" \
    compose_cmd --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" logs -f --tail=100
}

main() {
  validate_files
  validate_images
  deploy
  healthcheck
  show_logs

  log "Deploy concluido"
}

main "$@"
