{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/22.05.nix)
    (self + /mixins/nixos/settings/no-sleep.nix)
    (self + /mixins/nixos/zfs)
    (self + /mixins/nixos/dev)
  ];
}
