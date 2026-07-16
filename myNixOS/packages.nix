 {config, pkgs, ... }: {
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

    # Security / pentesting
    nmap
    bettercap
    john
    gobuster
    sherlock
    holehe
    seclists
    tcpdump
    burpsuite
    socat
    netcat
    wireshark

    # Dev / languages / runtimes
    gcc
    gdb
    python3
    jdk
    kdePackages.qtdeclarative

    # GUI applications
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

    #Fun
    pipes
    ani-cli
  ];
}
