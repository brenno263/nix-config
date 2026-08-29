{ pkgs, musnix, ... }:
{
  musnix = {
    enable = true;
    soundcardPciId = "00:1f.3";
  };

  # make sure to enable all this stuff
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   jack.enable = true;
  # };

  environment.systemPackages = with pkgs; [
    ardour
    reaper
  ];
}
