---
# flakes-pbel
title: Add Cloudflare MCP server to Claude settings
status: in-progress
type: task
priority: normal
created_at: 2026-10-22T14:34:36Z
updated_at: 2026-10-22T15:24:26Z
---

Cloudflare has an official hosted MCP server (Streamable HTTP, OAuth) at https://mcp.cloudflare.com/mcp covering Workers, R2, KV, D1, DNS, Workers AI and the rest of the platform. Add it declaratively next to the victoriametrics/victorialogs entries in mcpServers in packs/home/common/programs/claude/settings.nix:

```nix
cloudflare = {
  type = "http";
  url = "https://mcp.cloudflare.com/mcp";
};
```

Notes:
- Auth is OAuth through a browser on first connect. Fine on physical hosts; on headless containers it may need the existing mcp-oauth-bridge (packs/nixos/container/mcp-oauth-bridge.nix) or browser-login forwarding.
- Check whether Cloudflare's per-product servers (docs, observability, bindings, ...) are still offered and worth adding alongside the unified endpoint.

## Todo
- [x] Decide: unified endpoint only, or also per-product servers (unified only for now)
- [x] Decide: all hosts/containers, or physical hosts only (OAuth constraint) — all (packs/home/common); containers sign in via the OAuth bridge + ssh forward (flakes-q3l5)
- [x] Add entry to mcpServers in packs/home/common/programs/claude/settings.nix
- [ ] Activate home (mise run _activate-home) and complete the OAuth sign-in
- [ ] Verify the tools show up in a Claude Code session
