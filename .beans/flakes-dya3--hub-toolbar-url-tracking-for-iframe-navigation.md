---
# flakes-dya3
title: Hub toolbar URL tracking for iframe navigation
status: todo
type: bug
created_at: 2026-03-28T13:47:31Z
updated_at: 2026-03-28T13:47:31Z
---

The ingress hub page toolbar should display the current URL of the active iframe as the user navigates within it. Current implementation uses same-origin proxy (/s/<port>/) + setInterval polling but it's not working reliably.

## Context

The hub page (mixins/nixos/container/ingress.nix) embeds services in iframes. The toolbar at the top should show the current URL of the iframe content.

## Current approach (not working)

1. Caddy proxy routes: `handle_path /s/<port>/*` in hub config proxies to `localhost:<port>`, making iframe same-origin
2. Iframe src uses `/s/<port>/` instead of cross-origin `http://<port>.yolo.incus`
3. `setInterval` polls `frame.contentWindow.location` every 500ms
4. Translates proxy path back to real service URL for display

## Known issues

- Apps with absolute paths (e.g. `<a href="/dashboard">`) break under path-based proxy — the iframe navigates to `/dashboard` on the hub domain instead of `/s/<port>/dashboard`, which 404s
- The proxy routes are generated dynamically by `generate-ingress-config` (needs `ingress-sync` after rebuild)
- Needs investigation: may need to verify Caddy config is actually being regenerated with the HUB_ROUTES

## Alternative approaches to consider

- Inject postMessage script via response body rewriting (complex, no native Caddy support)
- Use a sub-path rewriting middleware or Caddy plugin
- Accept cross-origin limitation and only show base URL (simplest)
- Proxy all traffic through the Python sync API server (single-threaded bottleneck)

## Files

- `mixins/nixos/container/ingress.nix` — hub HTML, Caddy config generation, Python API server
