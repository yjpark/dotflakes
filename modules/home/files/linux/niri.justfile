backup-to-flakes:
  cp -v config.kdl ~/.flakes/modules/home/files/linux/niri.config.kdl

switch-to-local:
  rm -v config.kdl
  cp -v ~/.flakes/modules/home/files/linux/niri.config.kdl config.kdl
  nvim config.kdl
