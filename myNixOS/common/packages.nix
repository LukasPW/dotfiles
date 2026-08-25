 {config, pkgs, inputs, ... }: {
  environment.systemPackages = with pkgs; [
    fastfetch
    vim 
    git
    yazi
    kitty
    librewolf
    spotify
    easyeffects
    matugen
    starship
    waybar
    rofi
    awww
    cmatrix
    cava

    # Browsers
    librewolf
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Terminal / CLI
    psmisc
    bat
    btop
    eza
    fzf
    fd
    ncdu
    ripgrep
    ripgrep-all
    zoxide
    aria2
    jq
    fetch

    # Hyprland ecosystem (hyprland itself is a module, see below)
    hypridle
    hyprlock
    hyprpicker
    hyprshot

    #Niri Utils
    swaylock

    #QuickShell and related stuff
    quickshell

    # Wayland utilities
    grim
    slurp
    wl-clipboard
    cliphist
    wev
    nwg-look

    # Audio (pipewire/wireplumber themselves are a module, see below)
    pavucontrol
    pamixer
    playerctl
    cava

    # Dev / languages / runtimes
    gcc
    gdb
    python3
    jdk
    kdePackages.qtdeclarative

    # GUI applications
    obsidian
    thunderbird
    anki
    obs-studio
    vlc
    mpv
    godot
    lutris
    prismlauncher
    wine
    qalculate-gtk
    zenity
    webcord
    blender

    #Fun
    pipes
    ani-cli

    #Themes
    catppuccin-cursors.mochaDark
   (pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "mocha";
    })
    tela-icon-theme
  ];
}
