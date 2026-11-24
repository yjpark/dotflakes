---
# flakes-wg3n
title: Serve hub.yjpark.org from the hub VPS
status: completed
type: task
priority: normal
created_at: 2026-11-24T14:41:43Z
updated_at: 2026-11-24T14:55:19Z
---

Run the hub on the VPS with loopback TCP 15400 and WS 15401, Caddy TLS for hub.yjpark.org, and HUB_AUTH_TOKEN from SOPS.

Open only HTTP/HTTPS publicly. Keep hub state in memory and restart under systemd. The encrypted hub.env.txt needs the VPS age host key before deployment.
