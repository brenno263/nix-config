# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-inputs, ... }:

{
  imports =
    [
      flake-inputs.home-manager.nixosModules.default
      ./hardware-configuration.nix
      ./nix-settings.nix

      # USERS (make sure there's at least one!!)
      ../../users/b

      # CUSTOM MODULES
      # ../../modules/nvidia
      ../../modules/amdgpu.nix
      ../../modules/gnome
      ../../modules/gaming
      # ../../modules/godot-3-libxcrypt.nix
    ];

  # Users config
  userconfig.b = {
    enable = true;
    hostname = "lucy";
  };

  home-manager = {
    extraSpecialArgs = { inherit flake-inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Bootloader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # set kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;


  # set kernel module params
  # boot.extraModprobeConfig = ''
    # options usbhid mousepoll=8 jspoll=8 quirks=0x045e:0x028e:0x0400
  # '';

  # get wireshark workin
  programs.wireshark.enable = true;
  services.udev.extraRules = ''
    SUBSYSTEM=="usbmon", GROUP="wireshark", MODE="0640"
  ''; 



  networking.hostName = "hypergamma"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # undervolt
  # services.undervolt = {
  #   enable = true;
  #   coreOffset = -52;
  #   p1 = {
  #     limit = 85;
  #     window = 28;
  #   };
  #   p2 = {
  #     limit = 160;
  #     window = 0.004;
  #   };
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Use GDM even if we're not on Gnome
  services.xserver.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;

    # setting cuda support allows us to build all kind of apps
    # with gpu acceleration. Unfortunately they're not cached,
    # so this induces a LOT of compilation :/
    # I'm leaving it off unless I decide I really need it.
    # cudaSupport = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    vim
    wget
    curl
    git
    btop
    
    # gui apps
    qbittorrent
    filezilla
  ];

  system.stateVersion = "23.11"; # Did you read the comment?

}
