{ config, pkgs, ... }: {
  services.postgresql = {
    enable = true;
    ensureDatabases = ["test"];
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local sameuser     all     trust

      #type database DBuser origin-address auth-method
      # ipv4
      host sameuser      all     127.0.0.1/32   password
      host sameuser      all     10.0.1.1/24    password
    '';
  };
}
