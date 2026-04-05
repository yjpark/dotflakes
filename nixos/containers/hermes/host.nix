{ lib,...}: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "hermes";
  users.users.yj.linger = true;
}
