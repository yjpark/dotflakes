---
# flakes-7o0r
title: 'Monitoring: MCP servers for agents (VictoriaMetrics + VictoriaLogs)'
status: todo
type: task
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
parent: flakes-f2ju
blocked_by:
    - flakes-c6gm
    - flakes-m1as
---

Give agents (Claude Code etc.) query access to metrics and logs.

## Spec

- Official servers: `VictoriaMetrics-Community/mcp-victoriametrics` and `mcp-victorialogs` (Go). Not in nixpkgs → package with `buildGoModule` (local overlay/package in this repo; check how other custom packages are done here).
- Decide deployment:
  - (a) stdio MCP launched by the client (simplest; client config points `VM_INSTANCE_ENTRYPOINT` / VL URL at nearest hub over zerotier), installed via Home Manager; or
  - (b) HTTP/SSE MCP service on each hub (systemd), reachable over zerotier. Pick based on how containers' Claude Code reaches hosts.
- Raw HTTP APIs (PromQL `/api/v1/query`, LogsQL `/select/logsql/query`) are also usable directly by agents — document them.
- Wire into Claude Code MCP config (home-manager).

## Todo

- [ ] Package mcp-victoriametrics and mcp-victorialogs
- [ ] Choose stdio vs hub-hosted HTTP and implement
- [ ] Register in Claude Code config; test "which units failed on edger in the last hour?"
