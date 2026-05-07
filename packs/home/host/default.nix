{flake, lib, currentSystem, ...}: {
  imports = [
    (flake.inputs.self + /packs/home/common)
    ./common
  ] ++ (lib.optionals (lib.hasSuffix "-linux" currentSystem)
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
