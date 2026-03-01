{
  flake,
  lib,
  ...
}: {
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/niri/")
    (flake.inputs.autowire.gatherFiles_kdl ./.);
}
