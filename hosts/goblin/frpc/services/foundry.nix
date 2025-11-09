{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.goblin-frpc.services.foundry;
  inherit (lib) mkOption types;
  assertPropsSet =
    { cfg, props }:
    builtins.map (prop: {
      assertion = cfg.${prop} != null;
      message = "${prop} must be set.";
    }) props;
in
{
  options.goblin-frpc.services.foundry = {
    enable = lib.mkEnableOption "Enable the FoundryVTT service";
    hostname = mkOption {
      type = types.str;
    };
    volumePath = mkOption {
      type = types.str;
    };
    envFile = mkOption {
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
        "hostname"
        "volumePath"
        "envFile"
        "internalHTTPPort"
      ];
    });

    # ensure the volume exists
    systemd.tmpfiles.rules = [
      "d ${cfg.volumePath} 0755 1000 1000 -"
    ];
    virtualisation.oci-containers.containers.foundry = {
      image = "felddy/foundryvtt:sha-1a166b7";
      ports = [ "${toString cfg.internalHTTPPort}:30000/tcp" ];
      volumes = [ "${cfg.volumePath}:/data" ];
      environmentFiles = [ cfg.envFile ];
      autoStart = true;
    };

    goblin-frpc.proxies = [
      {
        name = "foundryvtt";
        type = "http";
        localIP = "127.0.0.1";
        localPort = cfg.internalHTTPPort;
        customDomains = [ cfg.hostname ];
        hostHeaderRewrite = "";
        requestHeaders.set.x-from-where = "frp";
        # healthCheck = {
        #   type = "http";
        #   # frpc will send a GET http request '/status' to local http service
        #   # http service is alive when it return 2xx http response code
        #   path = "/status.php";
        #   intervalSeconds = 60;
        #   maxFailed = 3;
        #   timeoutSeconds = 5;
        #   # set health check headers
        #   httpHeaders = [
        #     {
        #       name = "User-Agent";
        #       value = "FRP-Healthcheck";
        #     }
        #     {
        #       name = "x-from-where";
        #       value = "frp";
        #     }
        #   ];
        # };
      }
    ];
  };
}
