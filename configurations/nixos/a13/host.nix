{ config, lib, pkgs, ... }:

{
  networking.hostId = "80b98880";
  networking.hostName = "a13"; # alienware-13
  networking.interfaces.enp2s0.wakeOnLan.enable = true;

  networking.extraHosts = ''
      127.0.0.1   proxy
  '';

  # services.onedrive.enable = true;
}
