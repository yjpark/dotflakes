{ lib, pkgs, ... }:
let
  targetDir = ./.;
  dirContents = builtins.readDir targetDir;
  files = builtins.filter (name: name != "default.nix") (builtins.attrNames dirContents);
  withSources = builtins.listToAttrs (builtins.map (name: {
    name = ".local/bin/nushell_" + (lib.removeSuffix ".nu" name);
    value = {
      source = (targetDir + "/${name}");
      executable = true;
    };
  }) files);
in
{
  home.file = withSources;
}
