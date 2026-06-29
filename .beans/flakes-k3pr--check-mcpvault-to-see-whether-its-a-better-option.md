---
# flakes-k3pr
title: Check MCPVault, to see whether it's a better option for the markdowns
status: completed
type: task
priority: normal
created_at: 2026-03-25T15:22:51Z
updated_at: 2026-06-29T14:26:26Z
---

## Evaluation (research, 2026-06-29)

**MCPVault = [`bitbonsai/mcpvault`](https://github.com/bitbonsai/mcpvault)** (site: mcpvault.org) — a TypeScript/Node (≥18) **MCP server** that gives MCP-compatible AI agents safe read/write access to a folder of markdown files (no Obsidian needed). Exposes ~14 tools: read/write/patch/move notes, BM25 `search_notes`, frontmatter get/update (AST-aware YAML preservation), tags, vault stats; with path-traversal protection. Run via `npx @bitbonsai/mcpvault@latest /path/to/vault`.

### Is it a 'better option for the markdowns'?
**No — it's a different layer, not a replacement.** It does not compete with the current setup:
- `markdown-oxide` (LSP) serves **you** in the editor (completion, backlinks, go-to-def). [[flakes-7ih3]]
- `beans` CLI manages the `.beans/` issue markdowns for **you + agents**.
- **MCPVault serves AI agents** structured access to a notes vault. Complementary to markdown-oxide; largely redundant with `beans` for the `.beans/` dir (beans already has a CLI/GraphQL).

### NixOS feasibility
Not in nixpkgs; it's an npm package. Cleanest integration = register as an MCP server pointing `npx` at the notes vault; no system packaging needed.

### Verdict
The bean's 'better option' framing is a false either/or. **Recommendation: keep markdown-oxide; optionally TRIAL MCPVault as an MCP server against the notes vault** to give agents note access. Not urgent, not a replacement.

Sources: github.com/bitbonsai/mcpvault, mcpvault.org/install

## Summary of Changes

Research/evaluation task (no code changes). Identified MCPVault as bitbonsai/mcpvault (Node MCP server for markdown vaults). Conclusion: **not a 'better option'** — it's a complementary AI-agent access layer, not a replacement for markdown-oxide or beans. Recorded full assessment + sources above. Optional trial captured as a follow-up draft bean.
