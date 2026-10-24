{
  description = "My multi machine system flake :)";

  inputs = {
  nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
            ./common/security.nix
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
