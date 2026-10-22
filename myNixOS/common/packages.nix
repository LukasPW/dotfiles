 { config, pkgs, inputs, ... }: 
 {
  environment.systemPackages = with pkgs; [
    fastfetch
    vim 
    git
    yazi
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
    google-chrome

    #Terminal Emulator
    ghostty
    kitty

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
    vis

    #3D Printing Utils
    orca-slicer

    # Hyprland ecosystem (hyprland itself is a module, see below)
    hypridle
    hyprlock
    hyprpicker
    hyprshot

    #Niri Utils
    swaylock
     xwayland-satellite

    #QuickShell and related stuff
    quickshell
    kdePackages.qtdeclarative

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
    glibc
    tree-sitter
    go
    gopls
    man-pages
    man-pages-posix

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
    xarchiver
    tumbler

    #Fun
    pipes
    ani-cli

    #Themes
    #catppuccin-cursors.mochaDark
    layan-cursors


    #Keyring
    gnome-keyring
    seahorse
  ];
}
