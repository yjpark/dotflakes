---
# flakes-mqe9
title: 'MCP OAuth bridge: Mac-side forwarder + Phase 2 + e2e (external)'
status: draft
type: task
tags:
    - mcp
    - containers
created_at: 2026-06-30T00:19:08Z
updated_at: 2026-06-30T00:19:08Z
parent: flakes-qbvb
---

External (macOS host) half of the cross-container MCP OAuth bridge. The in-repo container half is done in flakes-wq6s (env pin + Caddy bridge site `<container-ip>:3118 -> 127.0.0.1:3118`). This bean covers the parts that live on the **Mac host / lima VM**, outside this NixOS flakes repo, plus end-to-end verification.

## Tasks
- [ ] **Mac launchd socat forwarder:** relay `localhost:3118` (where the Mac browser opens the OAuth callback) → `<container-ip>:3118` over the existing host→VM→container route (rides the vzNAT VM IP from the lima/incus routing setup, flakes-1huh).
- [ ] **Phase 2 — auto-open authorize URL (zero-touch):** Mac launchd listener that runs `open <url>`; container sets `BROWSER` to a script that ships the URL to it (+ an `xdg-open` shim). Restrict by **shared secret, NOT subnet** — the bridge NATs container traffic so the Mac sees the VM's source IP, not the container's.
- [ ] **End-to-end verification:** run an MCP OAuth flow from Claude Code inside the container; confirm the callback completes without manual URL-copy/curl.

## Notes / gotchas (verified against the CC binary)
- CC callback port default is a random ephemeral port; `MCP_OAUTH_CALLBACK_PORT` wins unconditionally (no availability check) → pinning to 3118 is mandatory (done container-side in flakes-wq6s).
- CC listener binds `127.0.0.1` only; redirect host/path hardcoded to `http://localhost:<port>/callback` (only the port is configurable).
- The container Caddy bridge binds the container IP only (not 0.0.0.0) so CC's own `127.0.0.1:3118` stays free.
- The bridge `mcp-oauth.conf` is (re)written whenever `ingress-sync` runs; ensure ingress-sync has run after boot before relying on the bridge.
- **Ubuntu containers:** the in-repo CC-side env pin (`environment.variables`) is NixOS-only. On Ubuntu containers the Caddy bridge still works (script falls back to port 3118), but CC's `MCP_OAUTH_CALLBACK_PORT` must be pinned via the Ubuntu user env separately if those containers run the OAuth flow.
