{ flake, ... }: {
  imports = [ (flake.inputs.self + /mixins/home/settings/kudo-node.nix) ];
}
