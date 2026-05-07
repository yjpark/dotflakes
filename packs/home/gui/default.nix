{flake, lib, ...}: {
  imports = [
    ./common
  ] ++ (lib.optionals (builtins.match ".*-linux" builtins.currentSystem != null)
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
