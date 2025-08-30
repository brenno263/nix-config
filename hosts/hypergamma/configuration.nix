# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, flake-inputs, ... }:

{
  imports =
    [
      flake-inputs.home-manager.nixosModules.default
      ./hardware-configuration.nix

      # USERS (make sure there's at least one!!)
      ../../users/b

      # CUSTOM MODULES
      # ../../modules/nvidia
      ../../modules/nix-settings.nix
      ../../modules/amdgpu.nix
      ../../modules/gnome
      ../../modules/cosmic.nix
      ../../modules/gaming
      # ../../modules/godot-3-libxcrypt.nix
      ../../modules/gnupg.nix
      ./tailscale.nix
    ];
  
  # Users config
  userconfig.b = {
    enable = true;
    hostname = "hypergamma";
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
  services.undervolt = {
    enable = true;
    coreOffset = -52;
    p1 = {
      limit = 85;
      window = 28;
    };
    p2 = {
      limit = 160;
      window = 0.004;
    };
  };

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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.b = {
  #   isNormalUser = true;
  #   description = "Brennan Seymour";
  #   extraGroups = [ "networkmanager" "wheel" ];
  #   packages = with pkgs; [
  #     neovim
  #   ];
  # };

  # Enable automatic login for the user.
  #services.displayManager.autoLogin.enable = true;
  #services.displayManager.autoLogin.user = "b";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  #systemd.services."getty@tty1".enable = false;
  #systemd.services."autovt@tty1".enable = false;

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
    htop
    btop
    dig
    traceroute
    nmap
    ungoogled-chromium
    vesktop
    brave
    pavucontrol
    parsec-bin
    godot_4
    signal-desktop-bin
    wireshark
    qbittorrent
    rpcs3
    libreoffice
    calibre
    obs-studio
    networkmanagerapplet

    # system stuff, maybe modularize this later?
    usbutils
    sysfsutils
    libinput
    gnumake
    vulkan-tools
    iputils
  ] ++ [
    ### packages from flakes ###
    # don't need blender-bin now that I have an amd gpu
    # flake-inputs.blender-bin-flake.packages.${flake-inputs.system}.default
    flake-inputs.agenix.packages.${flake-inputs.system}.default
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    exfat # for ventoy scripts
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  virtualisation.docker.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
