{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/nixos/host)
    (self + /packs/nixos/gui)
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/22.05.nix)
    (self + /mixins/nixos/zfs)
    (self + /mixins/nixos/lan/cn)
    (self + /mixins/nixos/settings/no-sleep.nix)
  ];
}
