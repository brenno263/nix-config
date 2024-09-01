{config, lib, pkgs, ...}: {
  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    gnome-extension-manager
    gnome-tweaks
    dconf-editor
    gnomeExtensions.appindicator
    gnomeExtensions.blur-my-shell
  ];

  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
  ];

  environment.gnome.excludePackages = with pkgs; [
      epiphany # gnome web browser
      totem # video player
      yelp # help menu
      geary # text editor
      gnome-text-editor
      gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      gnome-tour
    ];
}