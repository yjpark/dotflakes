{pkgs, ...}: {
  virtualisation.docker.enable = false;

  virtualisation.podman = {
    enable = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;
    extraPackages = [pkgs.zfs];
  };

  virtualisation.containers.registries.search = [
    "docker.io"
  ];

  # Note: need to create the zfs mount manually
  # bin/nixos/podman-setup-zfs-storage

  virtualisation.containers.registries.insecure = [
    "localhost:5000"
    "localhost:29003"
  ];

  environment.systemPackages = with pkgs; [
    arion
    podman-compose
    podman-tui
    docker-client
    distrobox
  ];
}
