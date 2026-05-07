{flake, pkgs, ...}: {
  imports = [
    ./common
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
