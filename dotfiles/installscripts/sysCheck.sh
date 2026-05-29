distroCheck() {
  if grep -qi "cachyos" /etc/os-release 2>/dev/null; then
    echo "cachyos"
  else
    echo "Arch"
  fi
}
GpuCheck() {
  if lspci 2>/dev/null | grep -qi "nvidia"; then
    echo "nvidia"
  else
    echo "amd"
  fi
}
CpuCheck() {
  if grep -qi "intel" /proc/cpuinfo 2>/dev/null; then
    echo "intel"
  else
    echo "amd"
  fi
}
BootloaderCheck() {
  if [[-f /boot/grub/grub.cfg ]]; then
    echo "grub"
  elif [[-d /boot/loader/entries ]]; then
    echo "systemd-boot"
  else
    echo "unknown"
  fi
}
