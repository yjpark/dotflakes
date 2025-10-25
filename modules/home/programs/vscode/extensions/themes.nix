{ config, pkgs, ... }: {
  programs.vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
    teabyii.ayu
  ];
}
