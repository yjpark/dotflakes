{ lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "onecli";
  users.users.yj.linger = true;
}
