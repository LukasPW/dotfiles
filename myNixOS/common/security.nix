{ config, lib, pkgs, ... }:

{
  # Import this module conditionally from your flake/configuration.nix
  # when you want the security/pentesting toolkit built into the system.

  environment.systemPackages = with pkgs; [
    # VPN / connectivity
    openvpn

    # Recon / scanning
    nmap
    masscan
    gobuster
    feroxbuster
    seclists

    # Network analysis
    tcpdump
    bettercap
    socat
    netcat
    wireshark

    # SMB / Windows / AD enumeration
    enum4linux
    smbclient-ng
    smbmap
    netexec

    # Web
    burpsuite
    sqlmap

    # Credential attacks
    john
    hashcat
    hydra

    # OSINT
    sherlock
    holehe

    # Remote access
    freerdp

    # Exploit lookup
    exploitdb

    # General
    python3

    # Reverse enginering
    ghidra
  ];
}
