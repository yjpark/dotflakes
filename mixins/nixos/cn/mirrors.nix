{pkgs, ...}: {
  nix.settings.substituters = pkgs.lib.mkBefore [
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/"
  ];
}
