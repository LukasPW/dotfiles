{ config, pkgs, ... }: {
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    source-han-sans
    maple-mono.NF-CN-unhinted
  ];
    fonts.fontconfig.defaultFonts = {
    monospace = [ "Maple Mono NF CN" ];
    sansSerif = [ "Maple Mono NF CN" "Source Han Sans" "JetBrainsMono Nerd Font" ];
    serif = [ "Maple Mono NF CN" "Source Han Sans" ];
  };
}
