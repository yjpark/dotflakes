{ config, lib, pkgs, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostId = "10e86483";
  networking.hostName = "g1"; # hp-g1

  networking.extraHosts = ''
      127.0.0.1   proxy
  '';
}
