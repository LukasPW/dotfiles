{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ((catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ "rimless" ];
      variant = "mocha";
    }).overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        find $out/share/themes -name index.theme -exec \
          sed -i 's/IconTheme=Tela-circle-Dark/IconTheme=Papirus-Dark/' {} \;
      '';
    }))
    papirus-icon-theme
    catppuccin-papirus-folders
  ];

  environment.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-mauve-standard+rimless";
    GTK_ICON_THEME = "Papirus-Dark";
  };

  environment.etc."xdg/gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=catppuccin-mocha-mauve-standard+rimless
    gtk-icon-theme-name=Papirus-Dark
    gtk-application-prefer-dark-theme=true
  '';
  environment.etc."xdg/gtk-4.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name=catppuccin-mocha-mauve-standard+rimless
    gtk-icon-theme-name=Papirus-Dark
    gtk-application-prefer-dark-theme=true
  '';
}
