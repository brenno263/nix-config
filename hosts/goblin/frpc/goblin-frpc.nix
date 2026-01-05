{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.goblin-frpc;
  inherit (lib) mkOption types;
in
{
  options.goblin-frpc = {
    enable = lib.mkEnableOption "Enable Module";
    group = mkOption {
      type = types.str;
    };
    tokenFile = mkOption {
      type = types.str;
      description = ''
        Path to a file (probably from Agenix) containing the frpc auth token.
      '';
    };
    proxies = mkOption {
      type = lib.types.listOf (types.attrs);
      default = [ ];
      description = "Specifiy frpc proxies. (examples in frpc-configfile.nix)";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.tokenFile != null;
        message = "You must set goblin-frpc.tokenFile";
      }
    ];

    environment.systemPackages = [
      pkgs.frp
    ];

    services.frp = {
      enable = true;
      role = "client";
      package = pkgs.frp;
      settings = {
        # your proxy name will be changed to {user}.{proxy}
        user = "goblin";
        serverAddr = "104.254.246.202";
        serverPort = 7000;
        # If true, don't retry if server login fails
        loginFailExit = true;
        # console or real logFile path like ./frpc.log
        log.to = "console";
        # trace, debug, info, warn, error
        log.level = "info";
        log.maxDays = 3;
        auth.method = "token";
        auth.tokenSource.type = "file";
        # This filepath should be passed into the module
        auth.tokenSource.file.path = cfg.tokenFile;
        # Set admin address for control frpc's action by http api such as reload
        webServer.addr = "127.0.0.1";
        webServer.port = 7400;
        webServer.user = "admin";
        webServer.password = "admin";
        # Enable golang pprof handlers in admin listener.
        webServer.pprofEnable = false;
        # connections will be established in advance, default value is zero
        transport.poolCount = 3;
        # Communication protocol used to connect to server
        # supports tcp, kcp, quic, websocket and wss now, default is tcp
        transport.protocol = "tcp";
        # If tls.enable is true, frpc will connect frps by tls.
        # Since v0.50.0, the default value has been changed to true, and tls is enabled by default.
        transport.tls.enable = true;
        # Specify udp packet size, unit is byte. If not set, the default value is 1500.
        # This parameter should be same between client and server.
        # It affects the udp and sudp proxy.
        udpPacketSize = 1500;
        proxies = cfg.proxies;
      };
    };
    # We override this property of the frp service so it has the neccessary group
    systemd.services.frp.serviceConfig.SupplementaryGroups = [ cfg.group ];
    systemd.services.frp.restartTriggers = [ cfg.tokenFile ];
  };
}
