{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.goblin-frpc.services.ssh-proxy;
  inherit (lib) mkOption types;
in
{
  options.goblin-frpc.services.ssh-proxy = {
    enable = lib.mkEnableOption "Enable the ssh service proxy";
    remotePort = mkOption {
      type = types.int;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.remotePort != null;
        message = "Remote port must be set";
      }
      {
        assertion = config.goblin-frpc.enable == true;
        message = "goblin-frpc must be enabled to use this service proxy";
      }
    ];

    goblin-frpc.proxies = [
      {
        # 'ssh' is the unique proxy name
        name = "ssh";
        type = "tcp";
        localIP = "127.0.0.1";
        localPort = 22;
        # Limit bandwidth for this proxy, unit is KB and MB
        transport.bandwidthLimit = "1MB";
        # Where to limit bandwidth, can be 'client' or 'server', default is 'client'
        transport.bandwidthLimitMode = "client";
        # If true, traffic of this proxy will be encrypted, default is false
        transport.useEncryption = false;
        # If true, traffic will be compressed
        transport.useCompression = false;
        # Remote port listen by frps
        remotePort = cfg.remotePort;
        # Enable health check for the backend service, it supports 'tcp' and 'http' now.
        # frpc will connect local service's port to detect it's healthy status
        healthCheck.type = "tcp";
        # Health check connection timeout
        healthCheck.timeoutSeconds = 3;
        # If continuous failed in 3 times, the proxy will be removed from frps
        healthCheck.maxFailed = 3;
        # Every 60 seconds will do a health check
        healthCheck.intervalSeconds = 60;
      }
    ];
  };
}
