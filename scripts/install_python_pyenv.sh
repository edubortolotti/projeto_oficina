#!/usr/bin/env bash
set -euo pipefail

PYTHON_VERSION="${PYTHON_VERSION:-3.11.9}"
PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
PROJECT_DIR="${PROJECT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
SHELL_RC="${SHELL_RC:-$HOME/.bashrc}"

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

install_build_dependencies() {
  log "Instalando dependencias de compilacao do Python"

  if command -v apt-get >/dev/null 2>&1; then
    run_sudo apt-get update
    run_sudo apt-get install -y \
      build-essential curl git libbz2-dev libffi-dev liblzma-dev libncursesw5-dev \
      libreadline-dev libsqlite3-dev libssl-dev llvm make tk-dev wget xz-utils zlib1g-dev
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    run_sudo dnf install -y \
      bzip2-devel curl findutils gcc gcc-c++ git libffi-devel make ncurses-devel \
      openssl-devel patch readline-devel sqlite-devel tk-devel xz-devel zlib-devel
    return
  fi

  if command -v yum >/dev/null 2>&1; then
    run_sudo yum install -y \
      bzip2-devel curl gcc gcc-c++ git libffi-devel make ncurses-devel openssl-devel \
      patch readline-devel sqlite-devel tk-devel xz-devel zlib-devel
    return
  fi

  if command -v apk >/dev/null 2>&1; then
    run_sudo apk add --no-cache \
      bash bzip2-dev curl gcc git libffi-dev linux-headers make musl-dev ncurses-dev \
      openssl-dev patch readline-dev sqlite-dev tk-dev xz-dev zlib-dev
    return
  fi

  log "Gerenciador de pacotes nao suportado. Instale manualmente as dependencias do pyenv."
}

install_pyenv() {
  if [ -d "$PYENV_ROOT" ]; then
    log "pyenv ja existe em $PYENV_ROOT"
    return
  fi

  log "Instalando pyenv em $PYENV_ROOT"
  git clone https://github.com/pyenv/pyenv.git "$PYENV_ROOT"
}

configure_shell() {
  touch "$SHELL_RC"

  if grep -q 'PYENV_ROOT' "$SHELL_RC"; then
    log "Configuracao do pyenv ja encontrada em $SHELL_RC"
    return
  fi

  log "Adicionando pyenv ao $SHELL_RC"
  {
    printf '\n# pyenv\n'
    printf 'export PYENV_ROOT="$HOME/.pyenv"\n'
    printf 'case ":$PATH:" in *":$PYENV_ROOT/bin:"*) ;; *) export PATH="$PYENV_ROOT/bin:$PATH" ;; esac\n'
    printf 'eval "$(pyenv init -)"\n'
  } >> "$SHELL_RC"
}

load_pyenv() {
  export PYENV_ROOT
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
}

install_python() {
  log "Instalando Python $PYTHON_VERSION via pyenv"
  if pyenv versions --bare | grep -qx "$PYTHON_VERSION"; then
    log "Python $PYTHON_VERSION ja esta instalado"
  else
    pyenv install "$PYTHON_VERSION"
  fi

  cd "$PROJECT_DIR"
  pyenv local "$PYTHON_VERSION"
}

create_venv() {
  cd "$PROJECT_DIR"

  log "Criando ambiente virtual em $PROJECT_DIR/.venv"
  python -m venv .venv
  . .venv/bin/activate

  python -m pip install --upgrade pip
  if [ -f requirements.txt ]; then
    python -m pip install -r requirements.txt
  fi

  log "Ambiente pronto"
  python --version
  python -m pip --version
}

main() {
  install_build_dependencies
  install_pyenv
  configure_shell
  load_pyenv
  install_python
  create_venv

  log "Para subir a API:"
  printf 'cd "%s"\n' "$PROJECT_DIR"
  printf 'source .venv/bin/activate\n'
  printf 'uvicorn client:app --host 0.0.0.0 --port 8000\n'
}

main "$@"
