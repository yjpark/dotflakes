{flake, pkgs, ...}: {
  imports = [
    (flake.inputs.self + /packs/home/common)
    ./common
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isLinux
    (flake.inputs.autowire.gatherImportsRecursively ./linux)
  );
}
