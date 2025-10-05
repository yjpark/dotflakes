{ flake, pkgs, ... }:
let
  inherit (flake) inputs;
  imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));
in
{
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
