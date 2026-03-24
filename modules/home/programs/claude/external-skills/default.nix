{ lib, ... }:
let
  dirs = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory")
      (builtins.readDir ./.)
  );
in
{
  home.file = builtins.listToAttrs (map (name: {
    name = ".claude/skills/${name}";
    value = {
      source = ./. + "/${name}";
      recursive = true;
    };
  }) dirs);
}
