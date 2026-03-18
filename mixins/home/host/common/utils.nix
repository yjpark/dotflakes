{pkgs, ...}: {
  home.packages = with pkgs; [
    # Secret
    age
    sops
    ssh-to-age

    # For nix and flakes
    omnix

    # slint-lsp
    # slint-viewer
    nil # nix language server
    markdown-oxide

    ast-grep 
    quint
    semgrep
  ];
}
