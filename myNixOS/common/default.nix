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
  ];
}
