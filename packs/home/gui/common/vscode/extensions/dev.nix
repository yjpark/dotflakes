{ config, pkgs, ... }:
{
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    visualjj.visualjj
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
    ionide.ionide-fsharp
    ms-dotnettools.csharp
    redhat.java
    github.vscode-pull-request-github
    skellock.just
    tamasfe.even-better-toml
    fill-labs.dependi
  ];
  home.packages = with pkgs; [
    nixfmt
  ];
}
