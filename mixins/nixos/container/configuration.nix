{ pkgs, ... }: {

  # Required for LXC/incus containers
  boot.isContainer = true;

  # Fix the CPU scheduling error
  nix.daemonCPUSchedPolicy = "batch";  # or "other"

  # Also recommended for containers:
  nix.daemonIOSchedClass = "best-effort";

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
