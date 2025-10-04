{ lib, ... }:
let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  withContents = builtins.listToAttrs (builtins.map (name: {
    name = lib.removeSuffix ".fish" name;
    value = builtins.readFile (targetDir + "/${name}");
  }) files);
in
{
  programs.fish.functions = withContents;
}
