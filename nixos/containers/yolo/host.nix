{ lib,...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "yolo";

  # kudo-node runs as a user service and must start without a login.
  users.users.yj.linger = true;
}
