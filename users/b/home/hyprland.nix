{
  config,
  lib,
  pkgs,
  pkgs-stable,
  flake-inputs,
  ...
}:
{
  wayland.windowManager.hyprland = {
    # clashes with UWSM
    systemd.enable = false;
    settings = {
      decoration = {
        shadow_offset = "0 5";
        "col.shadow" = "rgba(00000099)";
      };

      "$mod" = "SUPER";

      bind = [
        # Execute Rofi with only the SUPER key
        "$mod, Super_L, exec, pkill rofi || rofi -show drun"

        "$mod, F, exec, librewolf"

        "CONTROL ALT, T, exec, wezterm"
      ];

      # Startup Apps
      exec-once = [
        "hyprpanel"
      ];

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
    };
  };
}
