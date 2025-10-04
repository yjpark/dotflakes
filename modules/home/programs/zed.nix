{ config, pkgs, ... }: {
  programs.zed-editor = {
    enable = true;
    installRemoteServer = true;
    extensions = [
      "just" "nix" "fish"
    ];
  };
}
