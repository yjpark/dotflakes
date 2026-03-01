{
  home.file.".config/niri/justfile".source = ./niri.justfile;
  # https://github.com/Drakulix/cosmic-ext-extra-sessions/tree/main/niri
  home.file.".local/bin/start-cosmic-ext-niri".source = ./start-cosmic-ext-niri.bash;
  home.file.".local/bin/cosmic-ext-alternative-startup".source = ./cosmic-ext-alternative-startup;
}
