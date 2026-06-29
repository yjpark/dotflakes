---
# flakes-rv2o
title: Trial MCPVault as an MCP server for the notes vault
status: draft
type: task
tags:
    - tools
created_at: 2026-06-29T14:26:26Z
updated_at: 2026-06-29T14:26:26Z
---

Optional follow-up from flakes-k3pr evaluation. MCPVault (bitbonsai/mcpvault) is an npm MCP server exposing a markdown vault to AI agents (read/write/patch/search/frontmatter/tags). It complements markdown-oxide (editor LSP) rather than replacing it. If wanted, register it as an MCP server: `npx @bitbonsai/mcpvault@latest <vault-path>`, pointed at the notes vault. Decide the vault path and which agent client(s) to wire it into. Skip if agent note-access isn't needed.
