# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Users
    ../../users/b

    # Custom modules
    ../../modules/nix-settings.nix

    # Frpc bespoke custom module
    ./frpc/goblin-frpc.nix
    # Frpc custom services
    ./frpc/services/ssh-proxy.nix
    ./frpc/services/nextcloud.nix
    ./frpc/services/foundry.nix

  ];

  userconfig.b = {
    enable = true;
    hostname = "goblin";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "goblin"; # Define your hostname.

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the XFCE Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

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

  # Enable container services with podman;
  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    xscreensaver
    frp
  ];

  ## Services ##

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = true;
      AllowUsers = null;
      UseDns = true;
      X11Forwarding = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  age.secrets."nextcloud-pg-pass" = {
    file = ../../secrets/nextcloud-pg-pass.age;
    owner = "nextcloud";
  };

  users.groups."frp-secret" = { };
  age.secrets."frp-token" = {
    file = ../../secrets/frp-token.age;
    group = "frp-secret";
    mode = "0440"; # group-readable
  };

  age.secrets."foundry-env" = {
    file = ../../secrets/foundry-env.age;
  };

  # Custom FRP Services
  goblin-frpc = {
    enable = true;
    tokenFile = config.age.secrets.frp-token.path;
    group = "frp-secret";
    services = {
      ssh-proxy = {
        enable = true;
        remotePort = 2022;
      };
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud32;
        extraApps = with pkgs.nextcloud32Packages.apps; {
          inherit calendar contacts cookbook;
        };
        hostname = "nc.beensoup.net";
        datadir = "/run/media/spinning-rust/nextcloud-data";
        dbPassFile = config.age.secrets.nextcloud-pg-pass.path;
        internalHTTPPort = 8081;
      };
      foundry = {
        enable = true;
        hostname = "foundry.beensoup.net";
        volumePath = "/var/foundryvtt";
        envFile = config.age.secrets.foundry-env.path;
        internalHTTPPort = 8082;
      };
      matrix = {
        enable = true;
      };
    };
  };

  # services.vaultwarden = {
  #   enable = true;
  #   dbBackend = "sqlite";
  #   config = {
  #     # Config reference at https://github.com/dani-garcia/vaultwarden/blob/1.33.2/.env.template
  #     DOMAIN = "https://vault.beensoup.net";
  #     SIGNUPS_ALLOWED = false;
  #   };
  # };

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [ ];

  system.stateVersion = "24.11"; # NO TOUCH
}
