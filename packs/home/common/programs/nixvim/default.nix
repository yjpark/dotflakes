{
  flake,
  pkgs,
  ...
}: let
  inherit (flake) inputs;
  imports = inputs.autowire.gatherImports ./.;
in {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];
  programs.nixvim = {
    enable = true;
    imports = imports;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };
}
