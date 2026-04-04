{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    (self + /mixins/nixos/versions/26.05.nix)
    (self + /mixins/nixos/container)
    # hermes-agent installed via home-manager (yj@hermes), not as a NixOS service
  ];
}
