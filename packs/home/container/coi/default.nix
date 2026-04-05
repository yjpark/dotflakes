{
  flake,
  lib,
  ...
}: {
  home.file =
    (lib.mapAttrs'
      (flake.inputs.autowire.doPrefixName ".config/coi/")
      (flake.inputs.autowire.gatherFiles ".toml" ./.));
}
