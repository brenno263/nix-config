# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  flake-inputs,
  ...
}:
{
  imports = [
    flake-inputs.home-manager.nixosModules.default
    ./hardware-configuration.nix

    # USERS (make sure there's at least one!!)
    ../../users/aj

    # CUSTOM MODULES
    ../../modules/nix-settings.nix
    ../../modules/gnome.nix
    ../../modules/gaming.nix
    ../../modules/flatpak.nix
  ];

  # Users config
  userconfig.aj = {
    enable = true;
    hostname = "aj-framework";
  };

  home-manager = {
    extraSpecialArgs = { inherit flake-inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
  };

  # Bootloader.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      copyKernels = false;
      efiSupport = true;
      configurationLimit = 8;
      useOSProber = true;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  # set kernel version
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "aj-framework"; # Define your hostname.

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
  #   coreOffset = -50;
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Use GDM even if we're not on Gnome
  services.displayManager.gdm.enable = true;

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
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      vim
      wget
      curl
      git
      htop
      btop
      dig
      traceroute
      nmap
      vesktop
      brave
      pavucontrol
      signal-desktop-bin
      libreoffice
      calibre
      spotify
      google-chrome

      # system stuff, maybe modularize this later?
      usbutils
      sysfsutils
      iputils
    ]
    ++ [
      ### packages from flakes ###
    ];
  programs.zoom-us.enable = true;

  # Services

  services.openssh.enable = true;
  virtualisation.docker.enable = true;

  system.stateVersion = "25.05"; # NO TOUCH
}
