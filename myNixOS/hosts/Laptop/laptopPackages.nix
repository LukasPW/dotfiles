{config, pkgs, inputs, ...}: {
    environment.systemPackages = with pkgs; [

      brightnessctl
      networkmanagerapplet
      gnupg
      python3Packages.requests
      ciscoPacketTracer9
   ];
}
