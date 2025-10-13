{
  flake,
  lib,
  ...
}: {
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".local/bin/nushell_")
    (flake.inputs.autowire.gatherExecutables_nu ./.);
}
