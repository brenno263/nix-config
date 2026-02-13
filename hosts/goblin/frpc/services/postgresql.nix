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
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
        
        #type database user address   method
        host  all      all  localhost trust
      '';
      ensureDatabases = [ "b" ];
      ensureUsers = [
        {
          name = "b";
          ensureDBOwnership = true;
          ensureClauses = {
            superuser = true;
          };
        }
      ];
    };
  };
}
