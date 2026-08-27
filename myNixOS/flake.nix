/*
{
  description = "My system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    zen-browser = {
        url = "github:youwen5/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
      };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
      nixosConfigurations.not-arch-btw = nixpkgs.lib.nixosSystem{
          specialArgs = {inherit inputs;};
          modules = [ ./configuration.nix];
        };

  };
}
*/
{
  description = "My multi machine system flake :)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    zen-browser = {
        url = "github:youwen5/zen-browser-flake";
        inputs.nixpkgs.follows = "nixpkgs";
     };
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
            { nixpkgs.hostPlatform = "x86_64-linux";}
          ];
        };
      };
    };
}
