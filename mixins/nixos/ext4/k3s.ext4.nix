{...}: {
  services.k3s = {
    enable = true;
    role = "server";
  };
  networking.firewall.allowedTCPPorts = [
    6443
    80
    443
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 30000;
      to = 32767;
    }
  ];
}
