{lib, pkgs, ...}:
{
    programs.wireshark.package = pkgs.wireshark;
    programs.wireshark.enable = true;
}