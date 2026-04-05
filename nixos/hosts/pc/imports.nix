{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/nixos/host)
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/24.11.nix)
    (self + /mixins/nixos/ext4)
    (self + /mixins/nixos/lan/cn)
    (self + /mixins/nixos/settings/no-sleep.nix)
  ];
}
