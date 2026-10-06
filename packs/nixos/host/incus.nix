{pkgs, lib, ...}: {
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

  # Allow container→host DHCP and DNS; enable intra-zone forwarding for
  # container↔container traffic through the bridge.
  services.firewalld.zones.incus = {
    interfaces = [ "incusbr0" ];
    forward = true;
    masquerade = true;
    services = [ "dhcp" "dns" ];
    ports = [
      # Custom dnsmasq DNS port used by host ingress and containers
      { port = 5354; protocol = "tcp"; }
      { port = 5354; protocol = "udp"; }
    ];
  };

  # Firewalld policy: allow forwarding from incus zone to any zone (container→internet).
  # The NixOS firewalld module doesn't support policy objects, so we write the XML directly.
  environment.etc."firewalld/policies/incus-to-external.xml".text = ''
    <?xml version="1.0" encoding="utf-8"?>
    <policy target="ACCEPT">
      <ingress-zone name="incus"/>
      <egress-zone name="ANY"/>
    </policy>
  '';

  # Reload firewalld after policy file is written
  systemd.services.firewalld-incus-policy = {
    description = "Reload firewalld for incus forwarding policy";
    after = [ "firewalld.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${lib.getExe' pkgs.firewalld "firewall-cmd"} --reload";
    };
  };

  users.extraUsers.yjpark.extraGroups = ["incus-admin"];
}
