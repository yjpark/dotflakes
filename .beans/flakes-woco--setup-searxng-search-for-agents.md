---
# flakes-woco
title: Setup SearXNG search for agents
status: todo
type: feature
priority: normal
created_at: 2026-04-04T00:00:00Z
updated_at: 2026-04-05T06:24:06Z
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
