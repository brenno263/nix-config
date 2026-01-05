{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.goblin-frpc.services.nextcloud;
  inherit (lib) mkOption types;
  assertPropsSet =
    { cfg, props }:
    builtins.map (prop: {
      assertion = cfg.${prop} != null;
      message = "${prop} must be set.";
    }) props;
in
{
  options.goblin-frpc.services.nextcloud = {
    enable = lib.mkEnableOption "Enable the nextcloud service";
    package = mkOption {
      type = types.package;
    };
    extraApps = mkOption {
      type = types.attrs;
      default = { };
    };
    hostname = mkOption {
      type = types.str;
    };
    datadir = mkOption {
      type = types.str;
    };
    dbPassFile = mkOption {
      type = types.str;
    };
    internalHTTPPort = mkOption {
      type = types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.goblin-frpc.enable == true;
        message = "goblin-frpc must be enabled to use this service proxy";
      }
    ]
    ++ (assertPropsSet {
      cfg = cfg;
      props = [
        "package"
        "extraApps"
        "hostname"
        "datadir"
        "dbPassFile"
        "internalHTTPPort"
      ];
    });

    environment.systemPackages = [ cfg.package ];

    environment.etc."nextcloud-admin-pass".text = "password";
    services.nextcloud = {
      enable = true;
      package = cfg.package;
      hostName = cfg.hostname;
      maxUploadSize = "10G";
      datadir = cfg.datadir;
      config = {
        adminpassFile = "/etc/nextcloud-admin-pass";
        dbtype = "pgsql";
        dbhost = "localhost";
        dbuser = "nextcloud";
        dbname = "nextcloud";
        dbpassFile = cfg.dbPassFile;
      };
      settings = {
        trusted_domains = [ "192.168.5.227" ];
        overwriteprotocol = "https";
      };
      extraApps = cfg.extraApps;
      configureRedis = true;
      caching.redis = true;
    };

    # Override the nextcloud service's nginx entry so it listens on our custom port.
    services.nginx = {
      enable = true;
      virtualHosts."nc.beensoup.net" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = cfg.internalHTTPPort;
            ssl = false;
          }
        ];
      };
    };

    goblin-frpc.proxies = [
      {
        name = "nextcloud";
        type = "http";
        localIP = "127.0.0.1";
        localPort = cfg.internalHTTPPort;
        customDomains = [ cfg.hostname ];
        hostHeaderRewrite = "";
        requestHeaders.set.x-from-where = "frp";
        responseHeaders.set.foo = "bar";
        healthCheck = {
          type = "http";
          # frpc will send a GET http request '/status' to local http service
          # http service is alive when it return 2xx http response code
          path = "/status.php";
          intervalSeconds = 60;
          maxFailed = 3;
          timeoutSeconds = 5;
          # set health check headers
          httpHeaders = [
            {
              name = "User-Agent";
              value = "FRP-Healthcheck";
            }
            {
              name = "x-from-where";
              value = "frp";
            }
          ];
        };
      }
    ];

    # Postgres
    systemd.services.set-nextcloud-db-pass = {
      description = "Set password for the nextcloud user in pg";
      after = [
        "postgresql.service"
        "agenix.service"
      ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        PASS=$(cat ${cfg.dbPassFile})
        runuser -u postgres -- psql -U postgres -c "ALTER USER nextcloud WITH PASSWORD '$PASS';"
      '';
      path = [
        pkgs.util-linux
        pkgs.postgresql_15
      ];
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

    services.redis.servers."" = {
      enable = true;
      unixSocket = "/run/redis/redis.sock";
      unixSocketPerm = 770;
    };
  };
}
