
{ lib, pkgs, ... }:
let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  withSources = builtins.listToAttrs (builtins.map (name: {
    name = ".config/zellij/layouts/" + name;
    value = {
      source = (targetDir + "/${name}");
    };
  }) files);
in
{
  home.file = withSources;
}
