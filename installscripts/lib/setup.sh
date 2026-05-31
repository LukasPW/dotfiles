#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# CONFIG — update DOTFILES_REMOTE before use
# ─────────────────────────────────────────────
DOTFILES_REMOTE="https://github.com/YOURUSER/dotfiles.git"  # TODO: set your repo URL

# ─────────────────────────────────────────────
# GLOBALS — resolved at runtime
# ─────────────────────────────────────────────
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PERSONAL=false
DISTRO=""
GPU=""
CPU=""

# ─────────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────────
log()  { echo "[setup] $*"; }
warn() { echo "[setup][WARN] $*" >&2; }
die()  { echo "[setup][ERROR] $*" >&2; exit 1; }

# Run a command as the real (non-root) user
as_user() { sudo -u "$REAL_USER" "$@"; }

# Wrapper replicating your dotfiles alias — safe against spaces in paths
dotfiles_git() {
    as_user git --git-dir="$REAL_HOME/dotfiles/" --work-tree="$REAL_HOME" "$@"
}

# ─────────────────────────────────────────────
# DETECTION
# ─────────────────────────────────────────────
detect_distro() {
    if grep -qi "cachyos" /etc/os-release 2>/dev/null; then
        echo "cachyos"
    else
        echo "arch"
    fi
}

detect_gpu() {
    if lspci 2>/dev/null | grep -qi "nvidia"; then
        echo "nvidia"
    else
        echo "amd"
    fi
}

detect_cpu() {
    if grep -qi "intel" /proc/cpuinfo 2>/dev/null; then
        echo "intel"
    else
        echo "amd"
    fi
}

detect_bootloader() {
    if [[ -f /boot/grub/grub.cfg ]]; then
        echo "grub"
    elif [[ -d /boot/loader/entries ]]; then
        echo "systemd-boot"
    else
        echo "unknown"
    fi
}

# ─────────────────────────────────────────────
# PACKAGE INSTALLATION
# ─────────────────────────────────────────────
install_from() {
    local list="$SCRIPT_DIR/$1"
    [[ -f "$list" ]] || die "Package list not found: $list"
    log "Installing from $1..."
    pacman -S --needed --noconfirm - < "$list"
}

install_microcode() {
    log "Installing $CPU microcode..."
    pacman -S --needed --noconfirm "${CPU}-ucode"
}

install_vulkan() {
    case "$GPU" in
        nvidia) pacman -S --needed --noconfirm vulkan-icd-loader ;;
        amd)    pacman -S --needed --noconfirm vulkan-radeon vulkan-icd-loader ;;
    esac
}

# ─────────────────────────────────────────────
# KERNEL PARAM — nvidia-drm.modeset=1
# ─────────────────────────────────────────────
set_nvidia_kernel_param() {
    local bootloader
    bootloader=$(detect_bootloader)
    local param="nvidia-drm.modeset=1"

    case "$bootloader" in
        grub)
            if ! grep -q "$param" /etc/default/grub 2>/dev/null; then
                log "Adding $param to GRUB..."
                sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $param\"/" /etc/default/grub
                grub-mkconfig -o /boot/grub/grub.cfg
            else
                log "$param already present in GRUB config, skipping."
            fi
            ;;
        systemd-boot)
            local entry
            entry=$(find /boot/loader/entries -name "*.conf" | head -1)
            if [[ -z "$entry" ]]; then
                warn "No systemd-boot entry found — add '$param' to your boot entry manually."
            elif ! grep -q "$param" "$entry"; then
                log "Adding $param to systemd-boot entry: $entry"
                sed -i "s/^options \(.*\)/options \1 $param/" "$entry"
            else
                log "$param already present in systemd-boot entry, skipping."
            fi
            ;;
        unknown)
            # CachyOS March 2025+ uses Limine — automated editing not implemented
            # The param is likely already set by CachyOS installer for NVIDIA systems
            warn "Could not detect bootloader. If this is a fresh CachyOS install with NVIDIA,"
            warn "the kernel param is likely already set. Verify with: cat /proc/cmdline"
            warn "If missing, add '$param' to your Limine config manually."
            ;;
    esac
}

# ─────────────────────────────────────────────
# NVIDIA HYPRLAND CONFIG
# ─────────────────────────────────────────────
deploy_nvidia_hypr_config() {
    local hypr_dir="$REAL_HOME/.config/hypr"
    local target="$hypr_dir/nvidia.conf"

    as_user mkdir -p "$hypr_dir"

    log "Writing $target..."
    cat > "$target" << 'EOF'
# NVIDIA Blackwell (RTX 50xx) — sourced by hyprland.conf
# source = ~/.config/hypr/nvidia.conf  <-- add this line to hyprland.conf if not present

env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = GBM_BACKEND,nvidia-drm
env = NVD_BACKEND,direct
env = ELECTRON_OZONE_PLATFORM_HINT,auto

cursor {
    no_hardware_cursors = true
}
EOF
    chown "$REAL_USER:$REAL_USER" "$target"

    # Add source line to hyprland.conf if not already there
    local hyprconf="$hypr_dir/hyprland.conf"
    if [[ -f "$hyprconf" ]] && ! grep -q "nvidia.conf" "$hyprconf"; then
        log "Adding source line to hyprland.conf..."
        echo -e "\nsource = ~/.config/hypr/nvidia.conf" >> "$hyprconf"
        chown "$REAL_USER:$REAL_USER" "$hyprconf"
    elif [[ ! -f "$hyprconf" ]]; then
        warn "hyprland.conf not found yet — remember to add: source = ~/.config/hypr/nvidia.conf"
    fi
}

# ─────────────────────────────────────────────
# DOTFILE DEPLOYMENT
# ─────────────────────────────────────────────
deploy_dotfiles() {
    log "Deploying dotfiles..."

    # Clone bare repo if not already present
    if [[ ! -d "$REAL_HOME/dotfiles" ]]; then
        log "Cloning dotfiles repo..."
        as_user git clone --bare "$DOTFILES_REMOTE" "$REAL_HOME/dotfiles" \
            || die "Failed to clone dotfiles repo. Check DOTFILES_REMOTE and network access."
    fi

    # Attempt checkout — on conflict back up and retry
    if ! dotfiles_git checkout 2>/dev/null; then
        log "Conflicts detected — backing up existing files to ~/.dotfiles-backup/"
        local backup_dir="$REAL_HOME/.dotfiles-backup"
        as_user mkdir -p "$backup_dir"

        dotfiles_git checkout 2>&1 \
            | grep -E "^\s+" \
            | awk '{print $1}' \
            | while IFS= read -r file; do
                local dest="$backup_dir/$(dirname "$file")"
                as_user mkdir -p "$dest"
                log "  backing up: $file"
                mv "$REAL_HOME/$file" "$backup_dir/$file"
              done

        dotfiles_git checkout \
            || die "Dotfile checkout failed even after backup. Check $backup_dir."
    fi

    dotfiles_git config status.showUntrackedFiles no
    log "Dotfiles deployed successfully."
}

# ─────────────────────────────────────────────
# INSTALL FLOW
# ─────────────────────────────────────────────
run_install() {
    log "Distro: $DISTRO | GPU: $GPU | CPU: $CPU"

    install_from packages-core.txt
    install_microcode
    install_vulkan

    if [[ "$GPU" == "nvidia" ]]; then
        if [[ "$DISTRO" == "arch" ]]; then
            # CachyOS already installs nvidia-open during graphical setup
            install_from packages-nvidia.txt
        else
            log "CachyOS detected — skipping nvidia package install (already handled by installer)."
        fi
        set_nvidia_kernel_param
        deploy_nvidia_hypr_config
    fi

    if [[ "$PERSONAL" == "true" ]]; then
        install_from packages-personal.txt
    fi

    deploy_dotfiles
    log "Install complete."
}

run_uninstall() {
    warn "Uninstall will remove all core packages. This is destructive."
    read -rp "Are you sure? (yes/N): " confirm
    [[ "$confirm" == "yes" ]] || { log "Aborted."; exit 0; }
    pacman -R --noconfirm - < "$SCRIPT_DIR/packages-core.txt"
}

# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────
main() {
    [[ "$EUID" == 0 ]] || die "Run with sudo: sudo $0 [--install|--uninstall] [--personal]"
    [[ -n "$REAL_USER" && "$REAL_USER" != "root" ]] \
        || die "Could not determine the real user. Run with sudo from your user account, not as root directly."

    # Parse all flags before acting
    local action=""
    for arg in "$@"; do
        case "$arg" in
            --install)   action="install" ;;
            --uninstall) action="uninstall" ;;
            --personal)  PERSONAL=true ;;
            *)
                die "Unknown argument: $arg\nUsage: sudo $0 [--install|--uninstall] [--personal]"
                ;;
        esac
    done

    # Detect environment
    DISTRO=$(detect_distro)
    GPU=$(detect_gpu)
    CPU=$(detect_cpu)

    case "$action" in
        install)   run_install ;;
        uninstall) run_uninstall ;;
        "")
            # No flag — interactive fallback for your friend
            echo ""
            echo "  Dotfile & package installer"
            echo "  Detected: $DISTRO | GPU: $GPU | CPU: $CPU"
            echo ""
            read -rp "  Install packages and dotfiles? (y/N): " answer
            [[ "$answer" =~ ^[Yy]$ ]] || { log "Aborted."; exit 0; }
            run_install
            ;;
    esac
}

main "$@"
