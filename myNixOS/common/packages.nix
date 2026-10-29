 { config, pkgs, inputs, ... }: 
 {
  environment.systemPackages = with pkgs; [
    awww
    cava
    cmatrix
    easyeffects
    fastfetch
    git
    librewolf
    matugen
    rofi
    spotify
    starship
    vim 
    waybar
    yazi

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

    #Niri Xwl support
    xwayland-satellite

    #WM utilities
    swaylock
    swayidle

    #QuickShell and related stuff
    quickshell
    kdePackages.qtdeclarative
    libnotify

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
