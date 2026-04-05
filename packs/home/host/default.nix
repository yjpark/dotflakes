{flake, ...}: {
  imports = [
    (flake.inputs.self + /packs/home/common)
  ] ++ (flake.inputs.autowire.gatherImportsRecursively ./.);
}
