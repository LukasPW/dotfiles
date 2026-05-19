#!/bin/bash

set -euxo pipefail

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
