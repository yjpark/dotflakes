apply-extras host:
  just switch-to-local
  cat config.{{host}}.kdl >> config.kdl

switch-to-local:
  mv config.kdl config.backup.kdl
  cp config.backup.kdl config.kdl
  chmod 644 config.kdl

