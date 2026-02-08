{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable the COSMIC Desktop Environment.
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Makes screensharing work
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
}
