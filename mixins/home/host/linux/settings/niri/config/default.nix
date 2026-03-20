{ config, ... }: {
  home.file.".config/niri/config.kdl".text =
    builtins.readFile ./config.common.kdl + config.me.niri.extraConfig;
}
