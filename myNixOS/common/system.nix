{ config, pkgs, ...}: 
{
  
  #nixOS specific settings
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # kernelPackages
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Time zone and localisation
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };
    #Locale in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };
  #Locale/Keymap in console
  console.keyMap = "sv-latin1";

  #wayland Electron fixes
	environment.sessionVariables = {
 		 NIXOS_OZONE_WL = "1";
  		ELECTRON_OZONE_PLATFORM_HINT = "wayland";  # force instead of auto
	};
  
  #XDG Portal Setup
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  #Keyring setup
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;

  # USB block auto mounting
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Setting hyprland-session
  systemd.user.targets.hyprland-session = {
    description = "Hyprland compositor session";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };
}
