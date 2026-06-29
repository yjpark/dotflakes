---
# flakes-wq6s
title: Cross-container MCP OAuth callback bridge
status: todo
type: feature
tags:
    - mcp
    - containers
created_at: 2026-06-29T14:03:47Z
updated_at: 2026-06-29T14:03:47Z
parent: flakes-qbvb
---

Claude Code running inside a nested container does MCP OAuth, but the callback listener is loopback-only and the redirect host is hardcoded to `http://localhost:<port>/callback`. The browser opens on the Mac, so `localhost` resolves to the *Mac*, not the container — today this needs a manual URL-copy + in-container `curl` to finish the flow.

## Ground truth (from the CC binary)

- Callback port default is a *random ephemeral* port.
- `MCP_OAUTH_CALLBACK_PORT` env wins unconditionally (no availability check) — pinning is mandatory.
- Listener binds `127.0.0.1` only; redirect host/path is hardcoded (only the port is configurable, not the host).

## Fix — pinned-port loopback bridge

```
Mac browser -> http://localhost:3118/callback
  -> [Mac launchd]  socat 127.0.0.1:3118 -> <container-ip>:3118
  -> [container]    Caddy site  http://:3118 { bind <container-ip>; reverse_proxy 127.0.0.1:3118 }
  -> Claude Code listener @ 127.0.0.1:3118  (done)
```

1. Pin `MCP_OAUTH_CALLBACK_PORT=3118` in the container env.
2. Container-side bridge relays `<container-ip>:3118 -> 127.0.0.1:3118`. A socket bound to `lo` won't serve a connection arriving on `eth0`, so a bridge is required. Reuse the already-running reverse proxy (Caddy) instead of a new socat daemon.
   - **Gotcha:** a Caddy site-address host controls Host *matching*, not the listen interface. `http://<ip>:3118` listens on `0.0.0.0` and steals CC's `127.0.0.1:3118` (env port has no availability check). Use `http://:3118 { bind <ip> }` so it binds the container IP only, leaving loopback free for CC.
3. Mac forwarder = launchd socat over the existing host→container route.

## Phase 2 — auto-open the authorize URL (true zero-touch)

Mac launchd listener that runs `open <url>`; container sets `BROWSER` to a script that ships the URL to it (+ an `xdg-open` shim). Restrict by shared secret, **NOT** subnet — the bridge NATs container traffic so the Mac sees the VM's source IP, not the container's.

## Scope in this repo

- **In-repo (NixOS container configs under `nixos/containers/`):** the `MCP_OAUTH_CALLBACK_PORT=3118` env var and the Caddy `http://:3118 { bind <ip> }` site. Container IPs are already statically assigned (see `mixins/nixos/services/incus-ingress.nix`).
- **External (not managed by this flake):** the Mac-side launchd socat forwarder and the Phase-2 `open <url>` listener live on the macOS host (lima VM), outside this repo.
- **Verification caveat:** the end-to-end OAuth flow can only be confirmed against the live container + Mac; a build here proves the config evaluates, not that the bridge works.

## Todo

- [ ] Pin `MCP_OAUTH_CALLBACK_PORT=3118` in the relevant container env (yolo / dev container)
- [ ] Add Caddy site `http://:3118 { bind <container-ip>; reverse_proxy 127.0.0.1:3118 }` to the container's NixOS config
- [ ] Document the Mac-side launchd socat forwarder (external) in the bean / a README
- [ ] (Phase 2) `BROWSER` shim + xdg-open script + shared-secret auth
- [ ] Verify end-to-end against a live container
