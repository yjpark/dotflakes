---
# flakes-2ey6
title: Convert onecli-reseed to a manually-invoked script
status: completed
type: task
priority: normal
created_at: 2026-04-05T14:09:31Z
updated_at: 2026-04-05T14:10:08Z
---

Remove the systemd service for onecli-init-ca-and-secrets and replace with a plain onecli-reseed command. Launch is manual so systemd wantedBy/autostart causes more trouble than it's worth.

## Summary of Changes

- Renamed `initScript` → `reseedScript` with binary name `onecli-reseed`
- Added `reseedScript` to `environment.systemPackages` directly
- Removed `systemd.services.onecli-init-ca-and-secrets` block entirely
- Deleted `onecli-init-ca-and-secrets.bash` (was just `sudo systemctl start ...`)
- Removed auto-start block from `mise run _switch-host`
- Updated `mise run restart-onecli` to call `sudo onecli-reseed` directly
