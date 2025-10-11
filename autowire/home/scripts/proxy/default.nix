{ flake, lib, ... }:
{
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".local/bin/")
    (flake.inputs.autowire.gatherExecutables_bash ./.);
}
