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
    # OneCLI's gateway dials upstream directly, so its egress has to be
    # captured below the application and pushed through the host clash proxy.
    (self + /mixins/nixos/services/egress-proxy.nix)
    (self + /mixins/nixos/versions/26.05.nix)
  ];
}
