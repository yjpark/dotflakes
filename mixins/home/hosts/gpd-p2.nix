{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /mixins/home/settings/incus/edger.nix)
  ];
}
