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

  # Hint electron apps to use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      # Makes screensharing work
      xdg-desktop-portal-hyprland
      # Provides filepicker
      xdg-desktop-portal-gtk
    ];
  };

  # Required for screensharing
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
  };
}
