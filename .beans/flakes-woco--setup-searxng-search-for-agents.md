---
# flakes-woco
title: Setup SearXNG search for agents
status: completed
type: feature
priority: normal
created_at: 2026-04-04T00:00:00Z
updated_at: 2026-04-05T12:40:25Z
order: m
parent: flakes-qbvb
---

Deploy SearXNG as a self-hosted meta-search engine to provide web search capabilities for agents (spacebot, hermes, etc.).

- https://github.com/searxng/searxng

## Goals

- Run SearXNG as a service accessible to agent containers over the LAN
- Provide a search API endpoint agents can call (JSON format) without external API keys
- Keep configuration declarative via Nix

## Open Questions

- Run as NixOS system service in a dedicated incus container at 10.100.0.3
- Which search engines to enable by default?
- Authentication/rate-limiting for the API endpoint?
- Integration method: MCP server, direct HTTP API, or tool wrapper?

## Summary of Changes

- Created `nixos/containers/searxng/` NixOS container config:
  - Static IP 10.100.0.3, services.searxng with JSON format enabled
  - Engines: google, bing, duckduckgo, wikipedia, github
  - Listens on 0.0.0.0:8080; no auth needed (LAN-only)
  - Uses full container pack (ingress.nix auto-discovers port 8080)
- Registered "searxng" in `flake/nixos-configs.nix`
- Added searxng to `incus-ingress.nix` ingressContainers (10.100.0.3)
- Added `incus-launch-searxng.bash`
- JSON API: http://10.100.0.3:8080/search?q=\<query\>&format=json
- Caddy: searxng-8080.\<host\>.yjpark.org → http://10.100.0.3:8080
