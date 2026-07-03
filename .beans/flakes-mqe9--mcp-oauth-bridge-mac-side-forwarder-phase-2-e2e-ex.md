---
# flakes-mqe9
title: 'MCP OAuth: browser-open + callback forwarding (desktop + WSL)'
status: todo
type: feature
priority: normal
tags:
    - mcp
    - containers
created_at: 2026-06-30T00:19:08Z
updated_at: 2026-07-03T00:21:01Z
parent: flakes-qbvb
---

Completes the MCP OAuth bridge: the container-side callback relay is done (flakes-wq6s). This bean covers **opening the authorize URL where the human actually is** and **routing the callback back**, for the two real access patterns (there is no Mac/lima in this setup — superseding the original external-Mac framing).

## Access patterns
- **Case 1 — host Linux desktop → `incus exec` → container.** Browser = host `xdg-open`. Callback `localhost:3118` = the host.
- **Case 2 — Windows → WSL (Ubuntu, home-manager-managed by this repo) → `ssh host` → `incus exec` → container.** Browser = Windows default browser, opened from WSL via `wslview`/`cmd.exe /c start`. Callback `localhost:3118` = Windows → WSL localhost forwarding.

## Unification
The container always reaches the host at its **bridge gateway (`10.100.0.1`)**, self-discoverable inside the container via `ip -4 route show default` (must be derived *in the container*, not the attach wrapper — on the host `default` is the uplink). No hardcoded IPs; optional `me.hostBridgeIp` override for odd setups. Host-side listeners bind the incus bridge address (`incus network get incusbr0 ipv4.address`).

| | Case 1 (host desktop) | Case 2 (Windows→WSL→SSH) |
|---|---|---|
| Detect (attach) | no `SSH_CONNECTION`, `WAYLAND_DISPLAY` set | `SSH_CONNECTION` set |
| Open URL | container→`gateway:OPEN`→host `xdg-open` listener | container→`gateway:OPEN`→host `ssh -R`→WSL listener→`wslview` |
| Callback | host `127.0.0.1:3118 → container:3118` (socat/systemd-proxy) | WSL `ssh -L 3118:<container>:3118` |

## Phasing
- **Phase A (universal, no detection):** container `$BROWSER` (+ `xdg-open` shim) writes the URL to the human's TTY as **OSC 8 hyperlink + OSC 52 clipboard + plain text + bell**. Lands on whichever terminal the human is at (host desktop or Windows Terminal via WSL/SSH), survives zellij detach/reattach, one click. → child bean (implemented first).
- **Phase B (zero-click):** Case 1 host `systemd --user` `xdg-open` listener on the bridge IP; Case 2 WSL `wslview` listener + `ssh -R` back-tunnel + host sshd `GatewayPorts clientspecified`. Attach-time detection injects `BROWSER_ROUTE`; OSC stays the fallback for moved/stale sessions.

## Callback forwards (needed even in Phase A)
- Case 1: host socat/systemd-socket-proxyd `127.0.0.1:3118 → 10.100.0.100:3118`.
- Case 2: WSL `programs.ssh.matchBlocks.<host>` `LocalForward 3118 10.100.0.100:3118` (Windows localhost:3118 → WSL → host → container Caddy bridge → CC).

## Children
- Phase A — container browser-open script (OSC).
- Host-desktop side — callback socat + Phase B xdg-open listener.
- WSL side — callback LocalForward + Phase B wslview auto-open + host sshd GatewayPorts.
