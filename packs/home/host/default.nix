{flake, lib, ...}: {
  imports = [
    (flake.inputs.self + /packs/home/common)
    ./common
  ] ++ (lib.optionals (builtins.match ".*-linux" builtins.currentSystem != null)
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
