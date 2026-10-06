programs.sway = {
  enable = true;
  package = pkgs.swayfx;
  wrapperFeatures.gtk = true;

  # Runs before sway starts, so everything in the session inherits these,
  # including apps launched from keybinds.
  extraSessionCommands = ''
    export XDG_CURRENT_DESKTOP=sway
    export QT_QPA_PLATFORMTHEME=gtk3
  '';

  # Replaces the defaults (swaylock, foot, dmenu), which you don't use.
  extraPackages = with pkgs; [ swayidle grim slurp wl-clipboard wl-mirror ];

  extraOptions = [ "--unsupported-gpu" ];
};
