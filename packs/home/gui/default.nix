{flake, lib, currentSystem, ...}: {
  imports = [
    ./common
  ] ++ (lib.optionals (lib.hasSuffix "-linux" currentSystem)
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
