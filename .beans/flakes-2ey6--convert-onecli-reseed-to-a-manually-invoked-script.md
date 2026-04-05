---
# flakes-2ey6
title: Convert onecli-reseed to a manually-invoked script
status: in-progress
type: task
created_at: 2026-04-05T14:09:31Z
updated_at: 2026-04-05T14:09:31Z
---

Remove the systemd service for onecli-init-ca-and-secrets and replace with a plain onecli-reseed command. Launch is manual so systemd wantedBy/autostart causes more trouble than it's worth.
