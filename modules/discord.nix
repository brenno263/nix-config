{pkgs, ...}: {
  config = {
    environment.systemPackages = [ pkgs.webcord ];
  };
}
