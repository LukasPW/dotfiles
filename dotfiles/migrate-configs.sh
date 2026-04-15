#!/bin/bash

# Migrates configs from /etc/xdg/ to ~/.config/ and tracks them in dotfiles.
# Apps will prefer ~/.config/ over /etc/xdg/ by XDG spec.

DOTFILES='git --git-dir="$HOME/dotfiles/" --work-tree="$HOME"'

# Add any apps here that you suspect live under /etc/xdg/ instead of ~/.config/
APPS=(
  waybar
  hypr
  mako
  dunst
  rofi
  wofi
  foot
)

for app in "${APPS[@]}"; do
  ETC_PATH="/etc/xdg/$app"
  HOME_PATH="$HOME/.config/$app"

  # Skip if nothing exists in /etc/xdg/ for this app
  if [ ! -e "$ETC_PATH" ]; then
    continue
  fi

  # Skip if ~/.config/ version already exists
  if [ -e "$HOME_PATH" ]; then
    echo "[skip] $HOME_PATH already exists"
    continue
  fi

  echo "[copy] $ETC_PATH -> $HOME_PATH"
  sudo cp -r "$ETC_PATH" "$HOME_PATH"
  sudo chown -R "$USER:$USER" "$HOME_PATH"

  echo "[track] Adding $HOME_PATH to dotfiles"
  eval "$DOTFILES add $HOME_PATH"
done

echo ""
echo "Done. Review changes with:  dotfiles status"
echo "Then commit with:           dotfiles commit -m 'migrate configs from /etc/xdg'"
