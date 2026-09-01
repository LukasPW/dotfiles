{config, pkgs, inputs, ...}: {
    environment.systemPackages = with pkgs; [

      brightnessctl
      networkmanagerapplet

      claude-code
   ];
}
