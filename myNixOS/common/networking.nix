{ lib, ... }:
{
    networking.networkmanager.enable = true;
    networking.nftables.enable = lib.mkDefault true;
    networking.firewall = {
      enable = lib.mkDefault true;
      allowPing = lib.mkDefault false;
    };
  }
