#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
API_IMAGE="${ATRI_API_IMAGE:-atri-rpa-api:latest}"
WEB_IMAGE="${ATRI_WEB_IMAGE:-atri-rpa-web:latest}"
EXPORT_IMAGES="${EXPORT_IMAGES:-0}"
EXPORT_DIR="${EXPORT_DIR:-$PROJECT_DIR/dist/docker-images}"
NO_CACHE="${NO_CACHE:-0}"
PULL_BASE="${PULL_BASE:-1}"

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

validate_project() {
  cd "$PROJECT_DIR"

  [ -f Dockerfile.api ] || fail "Dockerfile.api nao encontrado em $PROJECT_DIR"
  [ -f Dockerfile.web ] || fail "Dockerfile.web nao encontrado em $PROJECT_DIR"
  [ -f package-lock.json ] || fail "package-lock.json nao encontrado em $PROJECT_DIR"
  [ -f requirements.txt ] || fail "requirements.txt nao encontrado em $PROJECT_DIR"
}

build_image() {
  local dockerfile="$1"
  local image="$2"
  shift 2

  local args=()
  if [ "$NO_CACHE" = "1" ]; then
    args+=(--no-cache)
  fi
  if [ "$PULL_BASE" = "1" ]; then
    args+=(--pull)
  fi

  log "Gerando imagem ${image} com ${dockerfile}"
  docker_cmd build "${args[@]}" -f "$dockerfile" -t "$image" "$@" .
}

export_images() {
  if [ "$EXPORT_IMAGES" != "1" ]; then
    return
  fi

  mkdir -p "$EXPORT_DIR"

  log "Exportando imagens para $EXPORT_DIR"
  docker_cmd save "$API_IMAGE" | gzip > "$EXPORT_DIR/atri-rpa-api.tar.gz"
  docker_cmd save "$WEB_IMAGE" | gzip > "$EXPORT_DIR/atri-rpa-web.tar.gz"

  log "Arquivos gerados:"
  printf '%s\n' "$EXPORT_DIR/atri-rpa-api.tar.gz"
  printf '%s\n' "$EXPORT_DIR/atri-rpa-web.tar.gz"
}

main() {
  validate_project

  log "Projeto: $PROJECT_DIR"
  log "Imagem API: $API_IMAGE"
  log "Imagem WEB: $WEB_IMAGE"

  build_image Dockerfile.api "$API_IMAGE"
  build_image Dockerfile.web "$WEB_IMAGE"

  log "Imagens disponiveis no Docker local"
  docker_cmd images "$API_IMAGE"
  docker_cmd images "$WEB_IMAGE"

  export_images

  log "Build concluido"
}

main "$@"
