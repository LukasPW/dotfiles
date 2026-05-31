installFrom() {
  local list="$SCRIPT_DIR/$1"
  [[ -f "$list" ]] || die "Package list not found: $list"
  log "Installing from $1..."
  pacman -S --needed --noconfirm - <"$list"
}

installMicrocode() {
  log "Installing $CPU microcode..."
  pacman -S --needed --noconfirm "${CPU}-ucode"
}

installVulkan() {
  case "$GPU" in
  nvidia) pacman -S --needed --noconfirm vulkan-icd-loader ;;
  amd) pacman -S --needed --noconfirm vulkan-radeon vulkan-icd-loader ;;
  esac
}
