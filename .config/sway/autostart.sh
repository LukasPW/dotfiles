#!/bin/sh
# Sway autostart - port of the hyprland.start handler in hyprland.lua.
# Started once by `exec` in the sway config. Needs chmod +x.

# Sway doesn't set this itself. Portals (xdg-desktop-portal-wlr) need it,
# and it's the fallback Compositor.qml checks.
#export XDG_CURRENT_DESKTOP="${XDG_CURRENT_DESKTOP:-sway}"

# Everything started from this script inherits this (qs, dunst, applets).
# Programs launched from keybinds won't - set it session-wide as well.
#export QT_QPA_PLATFORMTHEME=gtk3

is_systemd=false
[ "$(cat /proc/1/comm 2>/dev/null)" = systemd ] && is_systemd=true

# Is the program installed?
has() { command -v "$1" >/dev/null 2>&1; }

# Start a program in the background, only if it's installed.
start() { has "$1" && "$@" & }

start_polkit() {
    if $is_systemd; then
        systemctl --user start hyprpolkitagent
        return
    fi
    for p in /usr/libexec/hyprpolkitagent \
             /usr/lib/hyprpolkitagent/hyprpolkitagent \
             /usr/lib64/hyprpolkitagent/hyprpolkitagent; do
        if [ -x "$p" ]; then
            "$p" &
            return
        fi
    done
}

# Runs synchronously so the environment is in place before anything that
# D-Bus activates (portals, notifications).
vars="WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP SWAYSOCK"
if has dbus-update-activation-environment; then
    if $is_systemd; then
        dbus-update-activation-environment --systemd $vars
    else
        dbus-update-activation-environment $vars
    fi
fi

start gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
start_polkit
start qs
start dunst
has nm-applet && GDK_BACKEND=wayland nm-applet --indicator &
start easyeffects --gapplication-service
start blueman-applet

# Wallpaper: give the daemon a moment before restoring
start awww-daemon
has awww && { sleep 1; awww restore; } &

# Replaces hypridle. Match the timeouts to your hypridle.conf.
start swayidle -w \
    timeout 300 'qs ipc call lock lock' \
    timeout 600 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
    before-sleep 'qs ipc call lock lock'

if $is_systemd; then
    # Only exists if something defines it (e.g. home-manager's sway
    # module). Harmless if it doesn't.
    systemctl --user start sway-session.target 2>/dev/null
else
    start gentoo-pipewire-launcher restart
fi

has ghostty && GTK_IM_MODULE=simple ghostty --gtk-single-instance=true \
    --initial-window=false --quit-after-last-window-closed=false &
