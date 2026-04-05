{ pkgs, lib, ... }:
{
  #nix.package = lib.mkForce pkgs.lixPackageSets.stable.lix;
}
