---
# flakes-i4ol
title: 'Host-level ingress hub: one page per host for all service URLs'
status: in-progress
type: feature
priority: normal
created_at: 2026-10-17T09:51:16Z
updated_at: 2026-10-17T13:29:42Z
---

One place per host to find every service URL: `hub.<host>.yjpark.org` lists the host's own web UIs (VictoriaMetrics, VictoriaLogs, clash, onecli), copyable MCP endpoints, the live listening ports of every incus container, and the other site's hub. Replaces the per-container hub pages (`hub.<c>.incus` / `<c>-hub.<host>.yjpark.org`). Supersedes the "host-level hub" left out of flakes-bti9.

Scoped down from a Rust edger/hub links connector, which would conflict with the next stage of edger.

## Design

### Containers (`packs/nixos/container/ingress.nix`)
- Static Caddyfile, no generator: host regex `^(\d+)\.<c>\.incus$` → `localhost:<port>`, strip X-Frame-Options/CSP; HTTPS (`tls internal`) + HTTP. Still needed: dev servers bind 127.0.0.1, and agents use `<port>.<c>.incus` to test.
- Removed: generate-ingress-config, ingress-sync, ingress-sync-api, hub-index.html, services.json, hub dir, ingress-sync sudo rule.
- Kept: `ingress` status command (listening ports + URLs).
- MCP OAuth bridge site moves to `mcp-oauth-bridge.nix` as its own unit.
- Caddy internal CA → bundle merge becomes a oneshot after caddy.

### Hosts (`mixins/nixos/services/incus-ingress.nix`, pc + edger)
- `ingress.containers` — `{name, ip}` list option.
- `ingress.services.<name> = { title; group; upstream ? null; path ? "/"; url ? null; note ? null; }` — with `upstream`: `<name>.<host>.yjpark.org` Caddy route (frame headers stripped), opened in the iframe; without: copy-only row (MCP).
- `ingress.sites` default `[ "pc" "edger" ]`, self filtered out.
- Contributions: monitoring/hub.nix (`vm`, `logs`), monitoring/mcp.nix (two MCP rows), clash (`clash`, `/ui/`), onecli (`onecli`, replaces the hand-written route).
- `hub.<host>.yjpark.org`: `/` page, `/links.json` (Nix-generated), `/api/*` → hub API.
- `<c>-<port>.<host>.yjpark.org` unchanged; `<c>-hub` routes and dead `/s/<port>/` routes removed.
- Hub API (Python, 127.0.0.1, own user in incus-admin): `GET /api/containers` runs `incus exec -T <c> -- ss -tlnp` + cwd per running container, per-container errors; `GET /api/icon/<c>/<port>` favicon via `<c-ip>:80` Host `<port>.<c>.incus`.

### Page
Sidebar groups: This host → one per container (live ports → `https://<c>-<port>.<host>.yjpark.org`) → Other sites (new tab). Keeps iframe pane, compact mode, resize.

### Exposure
New subdomains share the existing `<c>-<port>` exposure (Caddy 80/443, firewalld public zone). Note: clash controller becomes reachable wherever host Caddy is.

## Tasks
- [x] Container: static Caddyfile, drop generator/hub/sync bits, keep `ingress`
- [x] Container: MCP OAuth bridge unit, CA bundle oneshot
- [x] Host: options (`containers`, `services`, `sites`), Caddy routes, links.json
- [x] Host: hub API service
- [x] Host: hub page with groups
- [x] Register monitoring, MCP, clash, onecli services
- [x] pc imports incus-ingress
- [x] Evaluate/build pc, edger, yolo, onecli, searxng
- [x] Deploy yolo in place, switch pc, verify page (onecli container unchanged, nothing to deploy)
- [ ] edger: switch later (with pending yolo update)

## Notes (2026-10-17)

- onecli container runs no Caddy, so `ingress.containers` entries carry `viaCaddy`; onecli ports are proxied to `<ip>:<port>` directly.
- Single CA bundle builder in containers: `ingress.extraCaFiles` (Caddy internal CA + OneCLI CA), rebuilt by `ingress-ca-bundle.{service,path}`. Fixes the old race where the ingress generator and onecli-ca-bundle each dropped the other's CA.
- MCP OAuth bridge is now a socat unit (`mcp-oauth-bridge.service`) bound to the container IP.
- Caddy needs the clash proxy env on CN hosts for Let's Encrypt (direct requests time out): added to `mixins/nixos/cn/proxy-env.nix`.
- Hub API needs a writable `$HOME` for the incus client (`StateDirectory=ingress-hub`).
- pc now runs systemd-resolved (pulled in by the ingress mixin), like edger.
- Verified on pc: hub, links.json, /api/containers, vm, logs, clash, onecli, onecli-10254 all 200 over HTTPS; unknown subdomains 404.
- Still to check by eye in a browser: clash dashboard (metacubexd) connecting to its backend via https://clash.<host>.yjpark.org, and iframe rendering of each UI.
- yolo redeployed with the final container config (`ingress` hides 3118/12345).
