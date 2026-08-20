{ config, pkgs, lib, ... }: 
  let
  sddm-astronaut = pkgs.sddm-astronaut.override {
      embeddedTheme = "cyberpunk";
      themeConfig = { };
    };
  in {
    # Desktop / window managers
    programs.hyprland.enable = true;
    programs.niri.enable = true;

    #services.displayManager.sddm.enable = true;
    environment.systemPackages = [ sddm-astronaut ];
    services.displayManager.sddm = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.sddm;
      extraPackages = with pkgs; [
      kdePackages.qtmultimedia
      kdePackages.qt5compat
      ];
      theme = "sddm-astronaut-theme";
    };
  
  services.xserver.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # Shell
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  users.users.aswdxtbyyn.shell = pkgs.zsh;
  programs.fzf.fuzzyCompletion = true;
  programs.fzf.keybindings = true;

  nixpkgs.config.allowUnfree = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  #laptop specific audio
  services.blueman.enable = true;


  # Gaming / virtualization
  programs.steam.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "aswdxtbyyn" ];

  # Security tooling
  programs.wireshark.enable = true;
  users.users.aswdxtbyyn.extraGroups = ["wireshark"];

  #Editor
  programs.neovim = {
	  enable = true;
	  defaultEditor = true;
  };

  # File Manager
  programs.thunar.enable = true;

  # Add Firefox
  programs.firefox.enable = true;

  #Dev Tools
  programs.nix-ld.enable = true;
  
  #Notifications
  services.dunst.enable = true;
  services.dunst.enableWayland = true;
}
