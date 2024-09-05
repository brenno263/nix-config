{config, lib, pkgs, ...}: {
  # GAMING
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;
  environment.sessionVariables = {
   STEAM_EXTRA_COMPAT_TOOLS_PATHS =
     "/home/b/.steam/root/compatibilitytools.d";
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protonup
    bottles
    gwe
    prismlauncher
    nethack
    vitetris
    techmino
  ];
}