{
  config,
  lib,
  pkgs,
  ...
}:
{
  # GAMING
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    protontricks.enable = true;
  };
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    steamtinkerlaunch
    # protontricks
    mangohud
    protonup-ng
    prismlauncher
    nethack
    vitetris
    r2modman
  ];
}
