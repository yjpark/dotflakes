{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    (self + /mixins/nixos/versions/22.05.nix)
    (self + /mixins/nixos/settings/no-sleep.nix)
    (self + /mixins/nixos/zfs)
  ];
}
