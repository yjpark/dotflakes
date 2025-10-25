{ config, pkgs, ... }: {
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    vscodevim.vim
    ms-vscode-remote.remote-ssh
    eamodio.gitlens
    shardulm94.trailing-spaces
    humao.rest-client
    yzhang.markdown-all-in-one
    streetsidesoftware.code-spell-checker
    redhat.vscode-yaml
  ];
}
