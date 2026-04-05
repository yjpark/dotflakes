---
# flakes-t9u2
title: Containerize OneCLI
status: todo
type: task
created_at: 2026-04-05T06:23:58Z
updated_at: 2026-04-05T06:23:58Z
parent: flakes-qbvb
---

Move OneCLI + postgres from podman-on-host to a dedicated incus container at 10.100.0.2. Update seeder to target container IP. Convert to NixOS service with local postgres (no more podman-in-podman).
