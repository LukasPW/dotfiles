# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  networking.hostName = "Desktop-NixOS-BTW"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;

  #add thunarFM
  #programs.thunar.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    powerManagement.enable = true;
  };
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia-container-toolkit.enable = true;

	#Fixing Discord
	environment.sessionVariables = {
 		 NIXOS_OZONE_WL = "1";
  		ELECTRON_OZONE_PLATFORM_HINT = "wayland";  # force instead of auto
	};




# configuration.nix

boot.kernelModules = [ "sch_cake" "ifb" ];

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
