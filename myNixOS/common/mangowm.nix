{pkgs, ... }:
{
    programs.mango.enable = true;
    systemd.user.targets.mango-session = {
      description = "mango compositor session";
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };
xdg.portal = {
  enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-wlr pkgs.xdg-desktop-portal-gtk ];
  config.mango = {
    default = [ "gtk" ];
    "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
    "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
  };
};
}
