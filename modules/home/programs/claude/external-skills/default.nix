{ lib, ... }:
let
  dirs = builtins.attrNames (
    lib.filterAttrs (_: type: type == "directory")
      (builtins.readDir ./.)
  );
in
{
  # Brainstorming
  # https://github.com/Jamie-BitFlight/claude_skills/tree/main/plugins/brainstorming-skill
  home.file = builtins.listToAttrs (map (name: {
    name = ".claude/skills/${name}";
    value = {
      source = ./. + "/${name}";
      recursive = true;
    };
  }) dirs);
}
