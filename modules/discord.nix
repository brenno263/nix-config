{pkgs, ...}: {
  config = {
    environment.systemPackages = with pkgs; [ discord webcord ];
  };
}
