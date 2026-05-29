deployNvidiaToHyprConf() {
  local hypr_dir="$REAL_HOME/.config/hypr"
  local target="$hypr_dir/nvidia.lua"

  as_user mkdir-p "$hypr_dir"

  log "Writing $target..."
  cat > "$target" << 'EOF'
  hl.env = LIBVA_DRIVER_NAME,nvidia
  hl.env = __GLX_VENDOR_LIBRARY_NAME,nvidia
  hl.env = GBM_BACKEND,nvidia-drm
  hl.env = NVD_BACKEND,direct
  hl.env = ELECTRON_OZONE_PLATFORM_HINT,auto
  hl.config({
    cursor = {
        no_hardware_cursors = true
    }
  })
  EOF
  chown "$REAL_USER:$REAL_USER" "$target"

  local hyprconf="$hypr_dir/hyprland.lua"
  if [[ -f "$hyprconf" ]] && ! grep -q "nvidia.conf" "$hyprconf"; then
    log "Adding source line to hyprland.lua"
    echo -e "\nrequire(\"nvidia\")"
    chown "$REAL_USER:$REAL_USER" "$hyprconf"
  elif [[! -f "$hyprconf" ]]; then
    warn "hyprland.lua not found yet - remember to add: require = nvidia.lua"
  fi
}
