{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  # Use individual container modules instead of the full container pack to
  # avoid pulling in ingress.nix and onecli-proxy.nix (which don't apply here).
  imports = [
    (self + /packs/nixos/common)
    (self + /packs/nixos/container/configuration.nix)
    (self + /packs/nixos/container/firewall.nix)
    (self + /packs/nixos/container/nix-ld.nix)
    (self + /packs/nixos/container/yj.nix)
    (self + /mixins/nixos/versions/26.05.nix)
  ];
}
