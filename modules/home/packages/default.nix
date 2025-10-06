{flake, ...}: {
  imports = flake.inputs.autowire.gatherImports ./.;
}
