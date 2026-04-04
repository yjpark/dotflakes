{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    (self + /mixins/nixos/versions/26.05.nix)
    (self + /mixins/nixos/container)
    (self + /mixins/nixos/containers/hermes.nix)
  ];
}
