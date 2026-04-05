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

  services.firewalld.zones.incus = {
    interfaces = [ "incusbr0" ];
    target = "ACCEPT";
    masquerade = true;
  };

  users.extraUsers.yjpark.extraGroups = ["incus-admin"];
}
