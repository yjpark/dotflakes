{ lib,...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostId = "f4769ef1";
  networking.hostName = "edger";
  networking.interfaces.enp37s0.wakeOnLan.enable = true;

  networking.extraHosts = ''
    127.0.0.1   proxy
  '';

  services.firewalld.zones.lan.interfaces = [ "wlp36s0" ];
}
