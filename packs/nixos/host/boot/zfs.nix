# https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS/3-system-configuration.html
{...}: {
  boot.supportedFilesystems = ["zfs"];
  # networking.hostId = "$(head -c 8 /etc/machine-id)";
  # boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
}
