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
      ];
      theme = "sddm-astronaut-theme";
    };
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Shell
  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
  users.users.aswdxtbyyn.shell = pkgs.zsh;
  programs.fzf.fuzzyCompletion = true;
  programs.fzf.keybindings = true;

  # GPU (nvidia-open, Blackwell / RTX 5070 Ti)
  hardware.nvidia.open = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.graphics.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Audio
  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;
  services.pipewire.wireplumber.enable = true;

  # Gaming / virtualization
  programs.steam.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;

  # Security tooling
  programs.wireshark.enable = true;
  users.users.aswdxtbyyn.extraGroups = ["wireshark"];


  #Dev Tools
  programs.nix-ld.enable = true;
  
  #Notifications
  services.dunst.enable = true;
  services.dunst.enableWayland = true;
}
