{flake, lib, ...}: {
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".claude/scripts/")
    (flake.inputs.autowire.gatherFiles ".py" ./.);
}
