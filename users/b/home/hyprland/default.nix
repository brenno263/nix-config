{
  config,
  pkgs,
  flake-inputs,
  userConfiguration,
  ...
}:
let
  wallpaper-file = ./geo-colors.png;
in
{
  home.packages = with pkgs; [
    hyprlauncher # application launcher
    hyprpaper # wallpaper utility
    hyprpicker # color picker from your screen
    hypridle # idle management  daemon
    hyprlock # screen locker
    hyprsunset # blue light filter, undetected in screenshots
    hyprpolkitagent # polkit authentication daemon, allows GUI applications for elevated permissions
    hyprsysteminfo # GUI application that displays system information
    hyprland-qt-support # provides QML style for hypr*qt6 apps
    hyprcursor # new cursor theme format
    hyprutils # library providing shared implementations of commonly used types across the hypr* ecosystem
    hyprlang # library provides parsing of the hypr configuration language
    hyprwayland-scanner # hw-s,is a utility to generate sources and headers for wayalnd protocol specifications (generates c++ implementations)
    aquamarine # lightweight linux rendering backend library
    hyprgraphics # library providing shared implementations of utilities related to graphics and resources, like loading images or color calculations
    hyprland-qtutils # small bunch of utility applications that hyprland might invoke (stuffs like dialogs and popups)
  ];

  xdg.configFile."hypr/xdph.conf".text = ''
    screencopy {
      max_fps = 60
      allow_token_by_default = true
    }
  '';

  programs.hyprpanel = {
    enable = true;
    systemd.enable = true;
    # settings = { };
  };

  home.file."${config.xdg.configHome}/hyprpanel" = {
    source = ./hyprpanel;
    recursive = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      wallpaper = [
        {
          # empty monitor is all
          monitor = "";
          # can be a dir
          path = "${wallpaper-file}";
          fit_mode = "cover";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    # use the existing package from nixos
    package = null;
    portalPackage = null;
    # clashes with UWSM
    systemd.enable = false;

    settings = {
      "$mod" = "SUPER";
      "$mon1" = "DP-2"; # main monitor
      "$mon2" = "DP-1"; # secondary monitor

      monitor = [
        # port, mode, position
        "DP-1, 2560x1440@60, 0x0, 1"
        "DP-2, 2560x1440@120, 0x1440, 1"
      ];

      # Startup Apps
      exec-once = [
        "systemctl --user enable --now hyprpaper.service"
        "hypridle"
        "hyprpanel"
      ];

      bind = [
        "$mod, space, exec, hyprlauncher"
        "$mod, return, exec, kitty"
        "$mod, C, killactive,"
        "$mod, F4, forcekillactive,"
        "$mod, M, exit,"
        "$mod, tab, exec, nautilus"
        "$mod, V, togglefloating,"
        "$mod, G, togglegroup,"
        "$mod, F, fullscreen, 0"
        # mod shift f for fullscreen w gaps
        "$mod SHIFT, F, fullscreen, 1"

        # example config marks these with "dwindle"?
        # "$mod, P, pseudo,"
        # "$mod, J, togglesplit,"

        # Move focus with mainMod + HJKL or arrow keys
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Switch workspace
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move active window to a workspace with shift
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # Media binds
        "$mod, Delete, exec, playerctl play-pause"
        "$mod, Home, exec, playerctl next"
        "$mod, End, exec, playerctl previous"
        "$mod, Prior, exec, hyprpanel "
        "$mod, Next, exec, wpctl set-volume @DEFAULT_AUDIO_SINK 5%-"
      ];

      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];

      workspace = [
        "1, persistent:true, monitor:$mon1, default:true"
        "2, persistent:true, monitor:$mon1"
        "3, persistent:true, monitor:$mon2, default:true"
        "4, persistent:true, monitor:$mon2, on-created-empty:spotify"
      ];

      windowrule = [
        {
          # Ignore maxmize requests from all apps
          name = "suppress-maximize-events";
          "match:class" = ".*";
          suppress_event = "maximize,fullscreen,fullscreenoutput";
        }
        {
          # Fix some dragging issues with XWayland
          name = "fix-xwayland-drags";
          "match:class" = "^$";
          "match:title" = "^$";
          "match:xwayland" = true;
          "match:float" = true;
          "match:fullscreen" = false;
          "match:pin" = false;

          no_focus = true;
        }
      ];

      general = {
        gaps_in = "3";
        gaps_out = "5";
      };

      decoration = {
        rounding = "6";
        rounding_power = "4.0";
        active_opacity = "1.0";
        inactive_opacity = "0.9";

        shadow = {
          enabled = true;
          range = "4";
          render_power = "3";
          sharp = false;
          ignore_window = true;
          color = "0xee1a1a1a";
          scale = "1.0";
        };
      };
    };
  };
}
