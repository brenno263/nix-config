{
  config,
  lib,
  pkgs,
  ...
}:
{

  # I'm using gdm so this isn't necessary
  # services.xserver.displayManager.cosmic-greeter.enable = true;

  # Enable the COSMIC Desktop Environment.
  services.desktopManager.cosmic.enable = true;
}
