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

  # Keychron Keybord functionallity setup
  hardware.keyboard.qmk.enable = true;
  hardware.keyboard.qmk.keychronSupport = true;  # pulls in keychron-udev-rules specifically
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0666"
  '';

  #wayland Electron fixes
	environment.sessionVariables = {
 		 NIXOS_OZONE_WL = "1";
  		ELECTRON_OZONE_PLATFORM_HINT = "wayland";  # force instead of auto
	};
  
  #XDG Portal Setup
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
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

  # A Test Script that Notifys me when some one pings me
  systemd.user.services.ping-notify = {
    description = "Notify via dunst when a ping hits this machine";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.writeShellScript "ping-notify" ''
        ${pkgs.systemd}/bin/journalctl -k -f -g 'PING_DROP:' --since now | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send -u normal "Ping detected" "$line"
        done
      ''}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };


}
