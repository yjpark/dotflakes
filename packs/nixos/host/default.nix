{flake, ...}: {
  imports = [
    (flake.inputs.self + /packs/nixos/common)
  ] ++ (flake.inputs.autowire.gatherImportsRecursively ./.);
}
