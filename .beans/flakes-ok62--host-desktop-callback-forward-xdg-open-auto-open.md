---
# flakes-ok62
title: 'Host-desktop: callback forward + xdg-open auto-open'
status: todo
type: task
tags:
    - mcp
created_at: 2026-07-03T00:21:01Z
updated_at: 2026-07-03T00:21:01Z
parent: flakes-mqe9
---

Host-desktop (Case 1) side of flakes-mqe9. The human is at the host Linux desktop; `incus exec` into the container.

## Callback (needed for Phase A too)
- [ ] Host forward `127.0.0.1:3118 → 10.100.0.100:3118` (socat or systemd-socket-proxyd unit) so the desktop browser's `localhost:3118/callback` reaches the container Caddy bridge → CC. Lives in a host (Linux) mixin.

## Phase B — zero-click auto-open
- [ ] Host `systemd --user` listener bound to the incus bridge IP that runs `xdg-open <url>` in the graphical session; authenticate with a shared secret.
- [ ] Container `$BROWSER` (Phase A script) gains a `host-desktop` route: POST URL+secret to `gateway:OPEN` (gateway = `ip -4 route show default`).
- [ ] Attach wrapper detects local desktop (`WAYLAND_DISPLAY`/`DISPLAY`, no `SSH_CONNECTION`) and injects `BROWSER_ROUTE=host-desktop`.

Bind the host listener to the incus bridge address (`incus network get incusbr0 ipv4.address`).
