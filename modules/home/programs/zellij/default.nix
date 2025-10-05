{ pkgs, ... }: {
  programs.zellij = {
    enable = true;
    # This will automatically start zellij for new shell, which make working with remote machine much harder
    enableFishIntegration = false;
  };
  # https://github.com/nix-community/home-manager/pull/4465
  # it's quite tricky to config mappings with home-manager
  home.file.".config/zellij/config.kdl".source = ./config.kdl;
  home.file.".config/zellij/layouts/zjstatus.kdl".source = ./layouts/zjstatus.kdl;
  home.file.".config/zellij/plugins/zjstatus.wasm".source = ./plugins/zjstatus.wasm;
}
