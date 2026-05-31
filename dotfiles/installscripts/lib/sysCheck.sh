distroCheck() {
  if grep -qi "cachyos" /etc/os-release 2>/dev/null; then
    echo "cachyos"
  else
    echo "arch"
  fi
}
gpuCheck() {
  if lspci 2>/dev/null | grep -qi "nvidia"; then
    echo "nvidia"
  else
    echo "amd"
  fi
}
cpuCheck() {
  if grep -qi "intel" /proc/cpuinfo 2>/dev/null; then
    echo "intel"
  else
    echo "amd"
  fi
}
bootLoaderCheck() {
  if [[ -f /boot/grub/grub.cfg ]]; then
    echo "grub"
  elif [[ -d /boot/loader/entries ]]; then
    echo "systemd-boot"
  else
    echo "unknown"
  fi
}
