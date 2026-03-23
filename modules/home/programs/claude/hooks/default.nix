{ lib, ... }:
let
  hooks = lib.filterAttrs (n: v: v == "regular" && n != "default.nix") (builtins.readDir ./.);
in {
  home.file = lib.mapAttrs' (name: _: {
    name = ".claude/hooks/${name}";
    value = { source = ./${name}; executable = true; };
  }) hooks;
}
