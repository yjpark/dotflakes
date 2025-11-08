{...}: {
  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "565799d8f6457a8a" #yjpark
    ];
  };
  networking.firewall.allowedUDPPorts = [
    9993
  ];
}
