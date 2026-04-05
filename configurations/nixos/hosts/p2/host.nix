{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostId = "a0a042e0";
  networking.hostName = "p2"; # gpd-p2

  networking.extraHosts = ''
      127.0.0.1   proxy
  '';
}
