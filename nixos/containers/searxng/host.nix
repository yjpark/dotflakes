{ lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "searxng";
  users.users.yj.linger = true;
}
