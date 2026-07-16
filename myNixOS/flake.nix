{
  description = "My system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
      nixosConfigurations.not-arch-btw = nixpkgs.lib.nixosSystem{
          modules = [ ./configuration.nix];
        };

  };
}
