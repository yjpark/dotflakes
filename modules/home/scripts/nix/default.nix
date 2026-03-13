{
  flake,
  pkgs,
  ...
}: {
  home.packages = flake.inputs.autowire.gatherScriptPackages_bash pkgs ./.;
}
