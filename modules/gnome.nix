{pkgs, ...}:
{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    environment.gnome.excludePackages = with pkgs.gnome; [
      cheese # webcam tool
      epiphany # gnome web browser
      pkgs.gnome-console
      gnome-contacts
      gnome-maps
      gnome-music
      totem
      yelp
      pkgs.gnome-tour
      geary
    ];
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
      gnome.gnome-tweaks
    ];
  };
}
