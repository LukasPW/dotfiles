{config, pkgs, inputs, ...}: {
    environment.systemPackages = with pkgs; [

      brightnessctl
      networkmanagerapplet
      gnupg
      claude-code
      python3Packages.requests
      ciscoPacketTracer9
   ];
}
