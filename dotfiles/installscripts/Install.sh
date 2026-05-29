#!/bin/bash

set -euxo pipefail

Target_DOTFILES="https://github.com/LukasPW/dotfiles.git"
#------------------
#Global Variables
#------------------
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONAL=false
DISTRO=""
GPU=""
CPU=""

if [[ "$EUID" != 0 ]]; then
  echo "Not running as root"
  exit 1
fi

pinstall() {
  echo "Running install logic"
  pacman -S --needed - <packages.txt
}

uninstall() {
  echo "Running uninstall logic"
  pacman -R - <packages.txt
}

main() {
  case "${1:-}" in
  --install) pinstall ;;
  --uninstall) uninstall ;;
  *)
    echo "Usage: $0 [--install|--uninstall]"
    exit 1
    ;;
  esac
}

main "$@"
