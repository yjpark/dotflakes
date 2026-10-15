{ lib, modulesPath, ... }: {

  # Normally only added by `build-image --image-variant lxc`. Importing it here
  # makes the plain toplevel (what nixos-rebuild / _switch-host builds) LXC-aware:
  # its installBootLoader repoints /sbin/init, so an in-place switch survives a
  # container restart instead of booting back into the original image system.
  imports = [ (modulesPath + "/virtualisation/lxc-container.nix") ];

  # Required for LXC/incus containers
  boot.isContainer = true;

  # LXC/Incus containers lack user namespaces required by Nix sandboxing
  nix.settings.sandbox = false;

  # Containers are accessed via incus exec, not SSH
  services.openssh.enable = false;

  # LXC containers lack CAP_SYS_NICE — any CPUSchedulingPolicy triggers sched_setscheduler()
  # which is blocked in containers. Force-remove it from the nix-daemon service unit.
  systemd.services.nix-daemon.serviceConfig = {
    CPUSchedulingPolicy = lib.mkForce "";
    IOSchedulingClass = lib.mkForce "";
    IOSchedulingPriority = lib.mkForce "";
  };

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
