{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    (self + /packs/nixos/host)
    (self + /packs/nixos/gui)
    flake.inputs.sops-nix.nixosModules.sops
    (self + /mixins/nixos/versions/22.05.nix)
    (self + /mixins/nixos/ext4)
    (self + /mixins/nixos/lan/my)
    (self + /mixins/nixos/services/nix-serve.nix)
    (self + /mixins/nixos/services/airplay.nix)
    (self + /mixins/nixos/services/incus-ingress.nix)
    (self + /mixins/nixos/services/onecli.nix)
    (self + /mixins/nixos/settings/no-sleep.nix)
  ];
}
