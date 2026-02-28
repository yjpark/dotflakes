switch-to-local:
  mv settings.json settings.backup.json
  cp settings.backup.json settings.json
  chmod 644 settings.json
