{ config, pkgs, ... }: {
  networking.firewall.allowedTCPPortRanges = [
    { from = 3000; to = 3999; }
    { from = 8000; to = 8999; }
    { from = 29000; to = 29999; }
  ];
}
