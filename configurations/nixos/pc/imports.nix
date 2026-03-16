{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/24.11.nix)
    (self + /mixins/nixos/ext4)
    (self + /mixins/nixos/host)
    (self + /mixins/nixos/settings/no-sleep.nix)
  ];
}
