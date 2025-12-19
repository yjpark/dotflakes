{...}: {
  networking.hostId = "9a8d434c";
  networking.hostName = "pc";
  networking.interfaces.eno1.wakeOnLan.enable = true;

  networking.extraHosts = ''
    127.0.0.1   proxy
  '';
}
