{ pkgs, inputs, ... }:
let
  pkgsPT = import inputs.nixpkgs-pt {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  };

  packettracer9 = pkgs.symlinkJoin {
    name = "packettracer9-wrapped";
    paths = [ pkgsPT.ciscoPacketTracer9 ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/packettracer9 --set QT_XCB_GL_INTEGRATION none
    '';
  };
in {
  environment.systemPackages = [
    packettracer9
  ];
}
