# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "Laptop-NixOS-BTW"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Enable UPower for battery status (used by the Quickshell battery module)
  services.upower.enable = true;

  #Enable bluetooth
  hardware.bluetooth ={
      enable = true;
      powerOnBoot = true;
      settings = {
        General ={
            Experimental = true;
            FastConnectable = true;
          };
        Policy = {
          AutoEnable = true;
        };
      };
  };
  # Firewall settings
  /*
  networking.nftables.enable = true;
   networking.firewall = {
   enable = true;
   allowPing = false;
   };
   */
  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  #services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "se";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "sv-latin1";
  /*
  # Enable CUPS to print documents.
  services.printing.enable = true;
  */
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."aswdxtbyyn" = {
    isNormalUser = true;
    description = "LukasPW";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;

  #add thunarFM
  programs.thunar.enable = true;

  #Add Neovim
  programs.neovim = {
	enable = true;
	defaultEditor = true;
};
 # GTK Setup
 environment.etc."xdg/gtk-3.0/settings.ini".text = ''
  [Settings]
  gtk-theme-name=catppuccin-mocha-mauve-standard+rimless
  gtk-icon-theme-name=Papirus-Dark
  gtk-cursor-theme-name=Adwaita
  gtk-application-prefer-dark-theme=1
 '';

 environment.etc."xdg/gtk-4.0/settings.ini".text = ''
  [Settings]
  gtk-theme-name=catppuccin-mocha-mauve-standard+rimless
  gtk-icon-theme-name=Papirus-Dark
  gtk-cursor-theme-name=Adwaita
  gtk-application-prefer-dark-theme=1
 '';

programs.dconf.enable = true;

 /*
  for future home manager
  gtk = {
      enable = true;
      theme = {
          name = "catppuccin-mocha-mauve-standard+default";
          package = pkgs.catppuccin-gtk.override {
              accents = ["mauve"];
              size = "standard";
              tweaks = [ "rimless" ];
              variant = "mocha";
            };
        };
    };
  */
  # List packages installed in system profile. To search, run:
  # $ nix search wget

/*#hardware.graphics.enable = true;
 hardware.nvidia = {
   open = true;
   modesetting.enable = true;
   powerManagement.enable = true;
 };
 */
services.xserver.videoDrivers = ["amdgpu"];

	environment.sessionVariables = {
 		 NIXOS_OZONE_WL = "1";
  		ELECTRON_OZONE_PLATFORM_HINT = "wayland";  # force instead of auto
	};




# configuration.nix

boot.kernelModules = [ "sch_cake" "ifb" ];
/*
systemd.services.cake-qos = {
  description = "Cake QoS (bufferbloat mitigation) on primary interface";
  wants = [ "network-online.target"];
  after = ["network-online.target"];
  wantedBy = [ "network-online.target" ];
  serviceConfig.Type = "oneshot";
  serviceConfig.RemainAfterExit = true;
  path = [ pkgs.iproute2 ];
  script = ''
    IFACE="enp7s0"   # e.g. eno1, enp3s0 — check with `ip link`
    IFB="ifb-cake"

    # --- Egress (upload) shaping, directly on the interface ---
    tc qdisc replace dev "$IFACE" root cake bandwidth 89mbit ethernet nat dual-srchost

    # --- Ingress (download) shaping, via IFB redirect ---
    ip link add "$IFB" type ifb 2>/dev/null || true
    ip link set "$IFB" up

    tc qdisc replace dev "$IFACE" handle ffff: ingress
    tc filter replace dev "$IFACE" parent ffff: matchall action mirred egress redirect dev "$IFB"

    tc qdisc replace dev "$IFB" root cake bandwidth 72mbit ethernet nat dual-dsthost
  '';

  preStop = ''
    tc qdisc del dev "enp7s0" root 2>/dev/null || true
    tc qdisc del dev "enp7s0" ingress 2>/dev/null || true
    ip link del ifb-cake 2>/dev/null || true
  '';
};
*/
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
