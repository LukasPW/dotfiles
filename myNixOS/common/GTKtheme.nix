{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "mocha";
    })
    papirus-icon-theme  # optional, if you want matching icons in Thunar
    catppuccin-papirus-folders
  ];

  environment.sessionVariables.GTK_THEME = "catppuccin-mocha-mauve-standard+rimless";

  # Fallback, in case GTK_THEME isn't picked up in some launch context (e.g. app launched via a script that doesn't inherit env)
  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=catppuccin-mocha-mauve-standard+rimless
    gtk-icon-theme-name=Papirus-Dark
    gtk-application-prefer-dark-theme=true
  '';
}
