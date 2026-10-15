{ flake, ... }: {
  # Send the container's direct (non-OneCLI) egress through the host clash
  # proxy — see mixins/nixos/services/egress-proxy.nix.
  imports = [ (flake.inputs.self + /mixins/nixos/services/egress-proxy.nix) ];
}
