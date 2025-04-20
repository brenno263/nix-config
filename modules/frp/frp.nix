{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.custom-frp;
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "frp-template.toml" cfg.settings;
  isClient = (cfg.role == "client");
  isServer = (cfg.role == "server");
in
{
  options = {
    services.custom-frp = {
      enable = lib.mkEnableOption "frp";

      package = lib.mkPackageOption pkgs "frp" { };

      role = lib.mkOption {
        type = lib.types.enum [
          "server"
          "client"
        ];
        description = ''
          The frp consists of `client` and `server`. The server is usually
          deployed on the machine with a public IP address, and
          the client is usually deployed on the machine
          where the Intranet service to be penetrated resides.
        '';
      };

      settings = lib.mkOption {
        type = settingsFormat.type;
        default = { };
        description = ''
          Frp configuration, for configuration options
          see the example of [client](https://github.com/fatedier/frp/blob/dev/conf/frpc_full_example.toml)
          or [server](https://github.com/fatedier/frp/blob/dev/conf/frps_full_example.toml) on github.
        '';
        example = {
          serverAddr = "x.x.x.x";
          serverPort = 7000;
        };
      };

      tokenFile = lib.mkOption {
        type = lib.types.str;
      };
    };
  };

  config =
    let
      serviceCapability = lib.optionals isServer [ "CAP_NET_BIND_SERVICE" ];
      executableFile = if isClient then "frpc" else "frps";
    in
    lib.mkIf cfg.enable {
      users.users.frp = {
        isSystemUser = true;
        group = "frp";
      };
      users.groups.frp = {};

      environment.systemPackages = [ cfg.package ];
      
      systemd.services = {
        frp-config-gen = {
          before = [ "frpc.service" ];
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
          script = ''
            CONF_DIR="/etc/frp"
            mkdir -p "$CONF_DIR"
            FRP_TOKEN=$(cat ${cfg.tokenFile})

            echo "tokenfile: ${cfg.tokenFile}, token: $FRP_TOKEN"

            sed -e "s|__FRP_TOKEN__|$FRP_TOKEN|g" ${configFile} > "$CONF_DIR/frp.toml"
          
            echo "generated config"
            cat "$CONF_DIR/frp.toml"

            chown -R frp:frp "$CONF_DIR"
            chmod -R 0500 "$CONF_DIR"
          '';
        };
        frp = {
          wants = lib.optionals isClient [ "network-online.target" "frp-config-gen.service" ];
          after = if isClient then [ "network-online.target" ] else [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          description = "A fast reverse proxy frp ${cfg.role}";
          serviceConfig = {
            Type = "simple";
            Restart = "on-failure";
            RestartSec = 15;
            StateDirectoryMode = lib.optionalString isServer "0700";
            # DynamicUser = true;
            User = "frp";
            Group = "frp";
            ExecStart = "${cfg.package}/bin/${executableFile} --strict_config -c /etc/frp/frp.toml";
            # Hardening
            UMask = lib.optionalString isServer "0007";
            CapabilityBoundingSet = serviceCapability;
            AmbientCapabilities = serviceCapability;
            PrivateDevices = true;
            ProtectHostname = true;
            ProtectClock = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectControlGroups = true;
            RestrictAddressFamilies = [
              "AF_INET"
              "AF_INET6"
            ] ++ lib.optionals isClient [ "AF_UNIX" ];
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            PrivateMounts = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [ "@system-service" ];
          };
        };
      };
    };

  meta.maintainers = with lib.maintainers; [ zaldnoay ];
}