{ lib, pkgs, ... }:
{
  networking.networkmanager.enable = true;
  networking.nftables.enable = lib.mkDefault true;
  networking.firewall = {
    enable = lib.mkDefault true;
    allowPing = lib.mkDefault false;
  };
  networking.nftables.tables."ping-detect" = {
    family = "inet";
    content = ''
      chain input {
        type filter hook input priority -5; policy accept;
        icmpv6 type echo-request limit rate 5/minute log prefix "PING_DROP: " level info
        icmp   type echo-request limit rate 5/minute log prefix "PING_DROP: " level info
      }
    '';
  };
}
