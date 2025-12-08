{ config, pkgs, ... }: {
  networking.firewall.allowedTCPPorts = [
    2342    # photoprism
  ];
}
