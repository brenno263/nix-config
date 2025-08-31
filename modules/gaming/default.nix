{config, lib, pkgs, ...}: {
  # GAMING
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    prismlauncher
    nethack
    vitetris
    r2modman
  ];
}