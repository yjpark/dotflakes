{
  flake,
  lib,
  ...
}: {
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/fish/completions/")
    (flake.inputs.autowire.gatherFiles_fish ./.);
}
