{
  flake,
  pkgs,
  ...
}: {
  environment.systemPackages = flake.inputs.autowire.gatherScriptPackages_bash pkgs ./.;
}
