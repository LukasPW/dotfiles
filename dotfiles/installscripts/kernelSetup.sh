NvidiaKernelSetup() {
  local bootloader
  bootloader = $(detect_bootloader)
  local param ="nvidia-drm.modset=1"

  case"$bootloader" in
    grub) 
      if ! grep -q "$param" /etc/default/grub 2>/dev/null; then
          log "Adding $param to grub..."
          sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $param\"/" /etc/default/grub
          grub-mkconfig -o /boot/grub/grub.cfg
      else
          log "$param already present in GRUB config, skipping"
      fi
      ;;
    systemd-boot)
      local entry
        entry=$(find /boot/loader/entries -name "*.conf" | head -1)
        if [[ -z "$entry"]]; then 
            warn "No systemd-boot entry found - add '$param' to your boot entry manually."
        elif ! grep -q "$param" "$entry"; then
            log "Adding $param to systemd-boot entry: $entry"
            sed -i "s/^options \(.*\)/options \1 $param/" "$entry"
        else
            log "$param already present in systemd-boot entry, skipping."
        fi
        ;;
    unknown)
      warn "Could not detect bootloader. If this is a fresh CachyOS install with NVIDIA,"
       warn "the kernel param is likely already set. Verify with: cat /proc/cmdline"
       warn "If missing, add '$param' to your Limine config manually."
    ;;
  esac
}
