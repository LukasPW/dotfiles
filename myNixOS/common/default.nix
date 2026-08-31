{ ... }:
{
  imports = [
    ./boot.nix
    ./networking.nix
    ./user.nix
    ./packages.nix
    ./programs.nix
    ./fonts.nix
    ./system.nix
    ./vpn.nix
    ./security.nix
    ./GTKtheme.nix
  ];
}
