source "$(dirname "${BASH_SOURCE[0]}")/installs.sh"
source "$(dirname "${BASH_SOURCE[0]}")/kernelSetup.sh"
source "$(dirname "${BASH_SOURCE[0]}")/deployNvidiaConfigs.sh"
runInstall() {
  log "Distro: $DISTRO | GPU: $GPU | CPU: $CPU"

  installFrom PackageSources/packages-core.txt
  installMicrocode
  installVulkan
  if [[ "$GPU" == "nvidia" ]]; then
    if [[ "$DISTRO" == "arch" ]]; then
      installFrom PackageSources/packages-nvidia.txt
    else
      log "CachyOS detected - skipping nvidia package install"
    fi
    deployNvidiaToHyprConf
    NvidiaKernelSetup
  fi

  if [[ "$PERSONAL" == "true" ]]; then
    installFrom PackageSources/packages-personal.txt
  fi

  dotfiles_git config status.showUntrackedFiles no
}

runUninstall() {
  warn "Uninstalling will remove all core packages. This is destructive."
  read -rp "Are you sure? (yes/N): " confirm
  [[ "$confirm" == "yes" ]] || {
    log "Aborted."
    exit 0
  }
  pacman -R --noconfirm - <"$SCRIPT_DIR/PackageSources/packages-core.txt"
}
