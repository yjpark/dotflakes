---
# flakes-bti9
title: 'Ingress hub page: service dashboard with iframe embedding'
status: completed
type: feature
priority: normal
created_at: 2026-03-28T05:29:53Z
updated_at: 2026-03-28T06:37:52Z
---

A hub web page served inside each container that auto-discovers running services and presents them as a navigable list with iframe embedding. Built on existing Caddy + ingress-sync infrastructure.

## Design

### Overview

Single hub page per container at `hub.<hostname>.incus` — left sidebar lists discovered services, right pane shows selected service in an iframe.

### Service Discovery

Extend existing `generate-ingress-config` script to also produce `/var/lib/ingress/services.json`:

- `ss -tlnp` → port + PID + process name (existing logic)
- `readlink /proc/<pid>/cwd` → working directory (new)
- Shorten cwd (strip home prefix, show last 1-2 path segments)
- Output format:
  ```json
  [{"port": 3000, "process": "node", "cwd": "my-app", "url": "https://3000.hostname.incus"}]
  ```
- Hub port excluded from the list (avoid self-reference)

### Hub Page (Caddy Templates)

- Static HTML file with embedded CSS/JS, served by Caddy `templates` directive
- JS fetches `services.json` at load time
- Left sidebar: service list showing `<short_path> <process> :<port>`
- Right pane: iframe loading selected service URL
- Iframe failure detection → fallback "open in new tab" link

### Caddy Config Changes

- New route: `hub.<hostname>.incus` serving the hub HTML + `services.json`
- Strip `X-Frame-Options` and rewrite `Content-Security-Policy` headers on all proxied routes (enables iframe embedding)
- Internal TLS unchanged

### Nix Integration

- All changes in `mixins/nixos/container/ingress.nix`
- Hub HTML as a Nix file/package
- `ingress-sync` regenerates both Caddy config and `services.json`
- `ingress` command unchanged

## Tasks

- [x] Extend `generate-ingress-config` to read `/proc/<pid>/cwd` and write `services.json`
- [x] Create hub HTML template (sidebar + iframe layout, JS service loader, iframe error fallback)
- [x] Add Caddy route for `hub.<hostname>.incus` serving hub page + services.json
- [x] Strip X-Frame-Options/CSP headers on proxied routes
- [x] Test with multiple running services

## Not in v1

- Manual label overrides
- Cross-container aggregation (host-level hub)
- Auto-refresh on service change (manual page reload for now)
- Service grouping/categorization


## Summary of Changes

Implemented ingress hub page for container service dashboard:

- **Hub page** served at `hub.<hostname>.incus` (internal) and `<container>-hub.<host>.yjpark.org` (external)
- **Service discovery** via `ss -tlnp` with process name and working directory from `/proc/<pid>/cwd`
- **Sidebar + iframe layout** with resizable sidebar, compact mode (icon toolbar), and service list sorted by port
- **Smart URL routing**: uses `https://<container>-<port>.<host>.yjpark.org` (real LE certs) when accessed externally, `http://<port>.<hostname>.incus` internally
- **Sync button** triggers `generate-ingress-config` via Python API, shows `ingress` status output in dismissable modal
- **Favicon proxy** at `/api/icon/<port>` fetches favicons from services (tries `/favicon.ico` then parses HTML `<link rel=icon>`), falls back to colored letter icons
- **Header stripping**: removes `X-Frame-Options` and `Content-Security-Policy` on proxied routes for iframe embedding
- **Host ingress**: added `<container>-hub` route to `incus-ingress.nix` for external access

Files changed:
- `mixins/nixos/container/ingress.nix` — hub HTML, sync API, enhanced generate-ingress-config
- `mixins/nixos/services/incus-ingress.nix` — hub route for host-level Caddy
