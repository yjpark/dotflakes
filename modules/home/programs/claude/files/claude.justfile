edit-settings:
  mv settings.json settings.backup.json
  cp settings.backup.json settings.json
  chmod 644 settings.json

edit-ccline-config:
  mv ccline/config.toml ccline/config.backup.toml
  cp ccline/config.backup.toml ccline/config.toml
  chmod 644 ccline/config.toml

backup-ccline-config:
  cp ccline/config.toml ~/.flakes/modules/home/programs/claude/files/ccline.config.toml
