# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Users
      ../../users/b

      # Custom modules
      ../../modules/nix-settings.nix
    ];
  
  userconfig.b = {
    enable = true;
    hostname = "goblin";
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "goblin"; # Define your hostname.
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
  hardware.pulseaudio.enable = false;
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
  users.users.b = {
    isNormalUser = true;
    description = "Brennan Seymour";
    extraGroups = [ "networkmanager" "wheel" ];
  };

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
    nextcloud31
    inkscape
    frp
  ];

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

  environment.etc."nextcloud-admin-pass".text = "password";
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    hostName = "nc.beensoup.net";
    maxUploadSize = "10G";
    datadir = "/run/media/spinning-rust/nextcloud-data";
    config = {
      adminpassFile = "/etc/nextcloud-admin-pass";
      dbtype = "pgsql";
      dbhost = "localhost";
      dbuser = "nextcloud";
      dbname = "nextcloud";
      dbpassFile = config.age.secrets."nextcloud-pg-pass".path;
    };
    settings = {
      trusted_domains = [ "192.168.5.227" ];
      overwriteprotocol = "https";
    };
    extraApps = with pkgs.nextcloud31Packages.apps; {
      inherit calendar contacts cookbook;
    };
    configureRedis = true;
    caching.redis = true;
  };


  age.secrets."nextcloud-pg-pass" = {
    file = ../../secrets/nextcloud-pg-pass.age;
    owner = "nextcloud";
  };
  systemd.services.set-nextcloud-db-pass = {
    description = "Set password for the nextcloud user in pg";
    after = [ "postgresql.service" "agenix.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      PASS=$(cat ${config.age.secrets."nextcloud-pg-pass".path})
      runuser -u postgres -- psql -U postgres -c "ALTER USER nextcloud WITH PASSWORD '$PASS';"
    '';
    path = [ pkgs.util-linux pkgs.postgresql_15 ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_15;
    ensureDatabases = [
      "nextcloud"
    ];
    ensureUsers = [
      {
        name = "nextcloud";
	ensureDBOwnership = true;
      }
    ];
  };

  services.redis = {
    enable = true;
    unixSocket = "/run/redis/redis.sock";
    unixSocketPerm = 770;
  };
   

  # We declare a custom group for permissioning who can read the secret file
  users.groups."frp-secret" = {};
  age.secrets."frp-token" = {
    file = ../../secrets/frp-token.age;
    group = "frp-secret";
    mode = "0440"; # group-readable
  };
  services.frp = {
    enable = true;
    role = "client";
    package = pkgs.frp;
    # frpc.nix holds a function that takes the secret file path and outputs frp client config
    settings = (import ./frpc.nix) config.age.secrets."frp-token".path;
  };
  # We override this property of the frp service so it has the neccessary group
  systemd.services.frp.serviceConfig.SupplementaryGroups = [ "frp-secret" ];
  systemd.services.frp.restartTriggers = [ config.age.secrets."frp-token".path ];
  


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
  ];
  networking.firewall.allowedUDPPorts = [];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
