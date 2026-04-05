{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/nixos/container)
    (self + /mixins/nixos/versions/26.05.nix)
  ];
}
