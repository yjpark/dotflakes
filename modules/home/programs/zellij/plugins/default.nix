{
  flake,
  lib,
  pkgs,
  ...
}: {
  home.file =
    lib.mapAttrs'
    (flake.inputs.autowire.doPrefixName ".config/zellij/plugins/")
    (flake.inputs.autowire.gatherFiles_wasm ./.);

  home.packages = [
    (pkgs.writeShellScriptBin "update-zellij-plugins-tab-bar-indexed"  ''
      #!/usr/bin/env bash
      cd ~/.flakes/modules/home/zellij/plugins/
      axel https://github.com/ivoronin/zellij-tab-bar-indexed/releases/latest/download/compact-bar.wasm
    '')
  ];

}
