{ flake, lib, ... }:
{
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/zellij/plugins/")
    (flake.inputs.autowire.gatherFiles_wasm ./.);
}
