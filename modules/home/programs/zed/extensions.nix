{pkgs, ...}: {
  programs.zed-editor.extensions = [
    "just"
    "nix"
    "fish"
    "toml"
    "yaml"
    "lua"
  ];
}
