{ config, pkgs, ... }:

{
  networking.hostId = "5a9d682e";
  networking.hostName = "dev-edger-dev";

  networking.extraHosts = ''
      127.0.0.1   proxy
  '';
}
