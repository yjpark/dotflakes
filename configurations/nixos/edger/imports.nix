{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    self.nixosModules.default
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/22.05.nix)
    (self + /mixins/nixos/ext4)
    (self + /mixins/nixos/host)
    (self + /mixins/nixos/gui)
    (self + /mixins/nixos/services/nix-serve.nix)
    (self + /mixins/nixos/services/airplay.nix)
    (self + /mixins/nixos/settings/no-sleep.nix)
  ];
}
