{
  description = "My multi machine system flake :)";

  inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-pt.url = "github:NixOS/nixpkgs/b1b875982b17dabde9b4a37f3e229e74913e6db3";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    {
      nixosConfigurations = {
        Laptop-NixOS-BTW = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./common
            ./hosts/Laptop/LaptopConf.nix
            ./hosts/Laptop/laptopPackages.nix
            ./hosts/Laptop/hardware-configuration.nix
            ./common/mangowm.nix
            ./common/windowmaker.nix
            ./common/security.nix
            ./hosts/Laptop/Packettracer.nix
            { nixpkgs.hostPlatform = "x86_64-linux";}
          ];
        };

        Desktop-NixOS-BTW = nixpkgs.lib.nixosSystem {
          specialArgs = {inherit inputs;};
          modules = [
            ./common
            ./hosts/desktopPC/DestopConf.nix
            ./hosts/desktopPC/DesktopPackages.nix
            ./hosts/desktopPC/hardware-configuration.nix
            ./common/mangowm.nix
            { nixpkgs.hostPlatform = "x86_64-linux";}
          ];
        };
      };
    };
}
