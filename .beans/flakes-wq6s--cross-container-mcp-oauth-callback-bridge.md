---
# flakes-wq6s
title: Cross-container MCP OAuth callback bridge
status: completed
type: feature
priority: normal
tags:
    - mcp
    - containers
created_at: 2026-06-29T14:03:47Z
updated_at: 2026-06-30T00:19:19Z
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

- [x] Pinned `MCP_OAUTH_CALLBACK_PORT=3118` (NixOS container env via `packs/nixos/container/mcp-oauth-bridge.nix`; also fed to the ingress-sync service)
- [x] Caddy bridge site emitted by the ingress generator (`generate-ingress-config.bash`, both nixos + home copies): detects container IP via `ip route get` and writes `/var/lib/caddy/mcp-oauth.conf` with `http://:3118 { bind <ip>; reverse_proxy 127.0.0.1:3118 }`. Verified with `caddy validate`
- [x] Mac-side launchd socat forwarder documented as external (see follow-up bean)
- [ ] (external follow-up) Phase 2: `BROWSER` shim + xdg-open script + shared-secret auth
- [ ] (external follow-up) Verify end-to-end against a live container + Mac forwarder

## Summary of Changes

Implemented the **in-repo (container-side) half** of the bridge and verified it; the macOS-host half is tracked separately in **flakes-mqe9**.

**Files**
- `packs/nixos/container/mcp-oauth-bridge.nix` (new): pins `MCP_OAUTH_CALLBACK_PORT=3118` (login-shell env for Claude Code) and passes the same port to the `ingress-sync` systemd service.
- `packs/nixos/container/ingress-scripts/generate-ingress-config.bash` and `packs/home/container/ingress/generate-ingress-config.bash` (identical edits): the ingress generator now detects the container IP (`ip -4 route get 1`) and writes `/var/lib/caddy/mcp-oauth.conf` = `http://:3118 { bind <ip>; reverse_proxy 127.0.0.1:3118 }`, before the existing atomic `caddy reload`. The IP-detect assignment uses `|| true` so a missing default route at early boot can't abort the whole generator under `set -euo pipefail`.

**Why a dedicated IP-bound site:** CC's callback listener binds `127.0.0.1:3118` only and its env-pinned port has no availability check, so the bridge must bind the container IP (eth0) — not `0.0.0.0` — leaving loopback free for CC.

**Verified:** `nix eval` confirms the env var + ingress-sync `Environment`; the full `yolo` system toplevel evaluates; `caddy validate` returns *Valid configuration* for the generated bridge site (real IP 10.100.0.100) in a Caddyfile mirroring the real structure; `bash -n` passes; both generator copies remain identical. A review subagent verified module merge, no port collision with the auto-generated `3118.<host>.incus` site, env delivery, and found the pipefail bug (fixed).

**Not done (external → flakes-mqe9):** the Mac launchd socat forwarder (`localhost:3118` → `<container-ip>:3118`), Phase 2 zero-touch auto-open, and live end-to-end verification — these live on the macOS host/lima VM, outside this repo.
