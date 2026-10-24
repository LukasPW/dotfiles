{config, pkgs, inputs, ...}: {
    environment.systemPackages = with pkgs; [
      cisco-packet-tracer_9
      brightnessctl
      networkmanagerapplet
      gnupg
      python3Packages.requests
   ];
}
