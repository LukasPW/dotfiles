#!/bin/sh
#more Claude BS FFS
# ~/.config/mango/autostart.sh
# Started by mango via: exec-once=sh ~/.config/mango/autostart.sh

# --- Debugging: uncomment both lines, log in, then read the log file ---
# exec >"$HOME/.cache/mango-autostart.log" 2>&1
# set -x

# ---------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------

# Succeeds if the program exists on PATH
has() {
  command -v "$1" >/dev/null 2>&1
}

# Run a command in the background, but only if its program exists.
# $1 = the full command line
# $2 = (optional) program to check for, when the command doesn't
#      start with the program name (env vars, sleep, etc.)
start() {
  bin="$2"
  if [ -z "$bin" ]; then
    bin=$(echo "$1" | cut -d' ' -f1)
  fi
  if has "$bin"; then
    sh -c "$1" &
  fi
}

# ---------------------------------------------------------------------
# Init system detection (PID 1 is "systemd" on NixOS, "init" on OpenRC)
# ---------------------------------------------------------------------
if [ "$(cat /proc/1/comm)" = "systemd" ]; then
  is_systemd="yes"
else
  is_systemd="no"
fi

# ---------------------------------------------------------------------
# Session environment
# Runs in the foreground on purpose: everything below needs these vars.
# ---------------------------------------------------------------------
vars="WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE MANGO_INSTANCE_SIGNATURE"

if [ "$is_systemd" = "yes" ]; then
  # $vars is deliberately unquoted so it splits into separate names
  # shellcheck disable=SC2086
  dbus-update-activation-environment --systemd $vars
else
  # shellcheck disable=SC2086
  dbus-update-activation-environment $vars
fi

# ---------------------------------------------------------------------
# Init-specific services
# ---------------------------------------------------------------------
if [ "$is_systemd" = "yes" ]; then
  # NixOS: polkit-gnome runs as a systemd user service,
  # started by graphical-session.target. Nothing to do here.
  :
else
  # Gentoo / OpenRC: start polkit-gnome directly
  for path in /usr/libexec/polkit-gnome-authentication-agent-1 \
              /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1; do
    if [ -x "$path" ]; then
      "$path" &
      break
    fi
  done

  start "gentoo-pipewire-launcher restart"
fi

# ---------------------------------------------------------------------
# Common programs (both machines)
# ---------------------------------------------------------------------
start "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
start "qs"
start "dunst"
start "GDK_BACKEND=wayland nm-applet --indicator" "nm-applet"
start "easyeffects --gapplication-service"
start "blueman-applet"
start "swayidle -w timeout 300 'qs ipc call lock lock' before-sleep 'qs ipc call lock lock'" swayidle

# Wallpaper: daemon first, restore after it has had a moment to start
start "awww-daemon"
start "sleep 0.5; awww restore" "awww"
