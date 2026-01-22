{
  home.file.".config/niri/justfile".source = ./niri.justfile;
  home.file.".config/niri/config.kdl".source = ./config.kdl;
  home.file.".config/niri/extras.a13.kdl".source = ./extras.a13.kdl;

  # https://github.com/Drakulix/cosmic-ext-extra-sessions/tree/main/niri
  home.file.".local/bin/niri-cosmic".source = ./start-cosmic-ext-niri.bash;
  home.file.".local/bin/cosmic-ext-alternative-startup".source = ./cosmic-ext-alternative-startup;
}
