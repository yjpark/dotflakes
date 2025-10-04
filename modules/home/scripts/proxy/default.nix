{ lib, pkgs, ... }:
let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  sources = ../sources;
  scripts = builtins.map (name:
    let
      scriptName = lib.removeSuffix ".bash" name;
      scriptContent = builtins.readFile (targetDir + "/${name}");
    in
      (pkgs.writeShellScriptBin scriptName scriptContent)
  ) files;
in
{
  home.packages = scripts;
}
