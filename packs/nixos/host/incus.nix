{pkgs, ...}: {
  virtualisation.incus = {
    enable = true;
    package = pkgs.incus;
    ui.enable = true;
    preseed = {
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "10.100.0.1/24";
            "ipv4.nat" = "true";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "dir";
        }
      ];
      profiles = [
        {
          name = "default";
          devices = {
            eth0 = {
              name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
              pool = "default";
              type = "disk";
            };
          };
        }
      ];
    };
  };

  # KVM support for VMs (modules are mutually exclusive; only the matching one loads)
  boot.kernelModules = ["kvm-amd" "kvm-intel"];

  # Allow container→host DHCP and DNS only; drop all other INPUT from containers.
  # Container↔container traffic goes through the bridge FORWARD chain (unaffected).
  services.firewalld.zones.incus = {
    interfaces = [ "incusbr0" ];
    masquerade = true;
    services = [ "dhcp" "dns" ];
    ports = [
      # Custom dnsmasq DNS port used by host ingress and containers
      { port = 5354; protocol = "tcp"; }
      { port = 5354; protocol = "udp"; }
    ];
  };

  users.extraUsers.yjpark.extraGroups = ["incus-admin"];
}
