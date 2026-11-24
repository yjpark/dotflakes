{ flake, ... }:

{
  imports = [
    flake.inputs.disko.nixosModules.disko
    (flake.inputs.self + /packs/nixos/host/zerotier/moon.nix)
  ];
}
