{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_15;
      authentication = [
        # allow all unix socket acces
        "local all all trust"
        # allow all TCP loopback access
        "host all all localhost trust"
      ];

      ensureUsers = [
        {
          name = "b";
          ensureClauses = {
            superuser = true;
          };
        };
      ];
    };
  };
}
