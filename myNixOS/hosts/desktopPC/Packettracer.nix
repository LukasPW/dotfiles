{ pkgs, inputs, ... }:
let
  pkgsPT = import inputs.nixpkgs-pt {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;   # needed; your global allowUnfree doesn't apply to this import
  };
in {
  environment.systemPackages = [
    pkgsPT.cisco-packet-tracer_9
  ];
}
