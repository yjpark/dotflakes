---
# flakes-woco
title: Setup SearXNG search for agents
status: draft
type: feature
priority: normal
created_at: 2026-04-04T00:00:00Z
updated_at: 2026-04-04T00:00:00Z
order: m
---

Deploy SearXNG as a self-hosted meta-search engine to provide web search capabilities for agents (spacebot, hermes, etc.).

- https://github.com/searxng/searxng

## Goals

- Run SearXNG as a service accessible to agent containers over the LAN
- Provide a search API endpoint agents can call (JSON format) without external API keys
- Keep configuration declarative via Nix

## Open Questions

- Run as NixOS system service or Home Manager user service in a dedicated container?
- Which search engines to enable by default?
- Authentication/rate-limiting for the API endpoint?
- Integration method: MCP server, direct HTTP API, or tool wrapper?
