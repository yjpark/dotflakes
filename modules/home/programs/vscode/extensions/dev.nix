{ config, pkgs, ... }: {
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    jnoortheen.nix-ide
    rust-lang.rust-analyzer
    zxh404.vscode-proto3
    ionide.ionide-fsharp
    ms-dotnettools.csharp
    redhat.java
    github.vscode-pull-request-github
    skellock.just
    tamasfe.even-better-toml
    serayuzgur.crates
    fill-labs.dependi
  ];
}
