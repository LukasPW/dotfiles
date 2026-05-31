#!/bin/bash

set -euxo pipefail
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

#----------------------
# Calling Child Scripts
# ---------------------
source "$(dirname "${BASH_SOURCE[0]}")/libs/helpers.sh"
source "$(dirname "${BASH_SOURCE[0]}")/libs/sysCheck.sh"
source "$(dirname "${BASH_SOURCE[0]}")/libs/mainProcesses.sh"
#--------------
# Main function
# -------------
main() {
   [[ "$EUID" == 0 ]] || die "Run with sudo: sudo $0 [--install|--uninstall] [--personal]"
   [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]] \
      || die "Could not determin the real user. Run with sudo from your user account, not as root"
  
  #Parsing Flags
  local action=""
  for arg in "$@"; do
      case "$arg" in
          --install) action="install" ;;
          --uninstall) action="uninstall" ;;
          --personal) PERSONAL=true ;;
          *)
              die "Unknown argument: $arg\nUsage: sudo $0 [--install|--uninstall] [--personal]"
              ;;
      esac
  done

  # Detect environment
  DISTRO=$(distroCheck)
  GPU=$(gpuCheck)
  CPU=$(cpuCheck)

  case "$action" in
      install) runInstall ;;
      uninstall) runUninstall ;;
      "")
          #No flag, falls back to core install
          echo ""
          echo " Package installer"
          echo " Detected: $DISTRO | GPU: $GPU | CPU: $CPU"
          echo ""
          read -rp " install packages? (y/N): " answer
          [[ "$answer" =~ ^[Yy]$ ]] || {log "Aborted."; exit 0;}
          runInstall
          ;;
  esac
}


main "$@"
