{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Enable the FLATPAK
  services.flatpak.enable = true;

  # Add a nice software browser to grab flatpak packages
  environment.systemPackages = [
    pkgs.cosmic-store
  ];

  # Makes sure flathub is available at boot
  systemd.services.flatpak-repo-setup = {
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };
}
