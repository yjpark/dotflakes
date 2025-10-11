{ flake, lib, ... }:
{
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/zellij/layouts/")
    (flake.inputs.autowire.gatherFiles_kdl ./.);
}
