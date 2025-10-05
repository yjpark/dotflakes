{ pkgs, ... }: {
  imports =
    with builtins;
    map
      (fn: ./${fn})
      (filter (fn: fn != "default.nix") (attrNames (readDir ./.)));

  programs.zellij = {
    enable = true;
    # This will automatically start zellij for new shell, which make working with remote machine much harder
    enableFishIntegration = false;
  };
}
