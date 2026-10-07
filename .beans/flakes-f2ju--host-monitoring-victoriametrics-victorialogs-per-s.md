---
# flakes-f2ju
title: 'Host monitoring: VictoriaMetrics + VictoriaLogs, per-site replicated hubs'
status: todo
type: epic
created_at: 2026-10-07T13:38:52Z
updated_at: 2026-10-07T13:38:52Z
---

Monitor the always-on hosts (initially **pc** @ site 102 and **edger** @ site 401): host health, systemd unit state, and service logs, with a web UI and an API/MCP surface for agents.

## Decisions (2026-10-07)

- **Stack: VictoriaMetrics + VictoriaLogs.** Chosen over Beszel (no logs), Netdata (heavier, modern UI unfree/cloud-leaning) and Grafana+Prometheus+Loki (heaviest). Both have NixOS modules in our nixpkgs (`services.victoriametrics`, `services.victorialogs` v1.49).
- **Topology: one hub per site, replicated (dual-write).** pc is the hub for 102, edger for 401. Every monitored host runs agents that write to **all** hubs, so each hub holds the full dataset:
  - per-site autonomy when the zerotier link is down;
  - agents buffer to disk per remote URL and replay on reconnect (no gaps);
  - any hub answers queries for every host (UI/API/MCP can point at either).
  - Rejected: query-time federation (store once, fan-out via vmselect/vlselect or multi-datasource) — more moving parts, cross-site view lost when link down, only pays off at scale.
- **Access: zerotier only.** No cloudflared exposure. zerotier (172.22.0.0/16) is already in the firewalld `trusted` zone (`packs/nixos/host/zerotier/zerotierone.nix`); bind on 0.0.0.0 or zerotier IP, do not open in `lan`/public zones unless needed.
- **Grafana: later, optional** — start with built-in vmui (VM) and the VictoriaLogs web UI (`/select/vmui`).

## Data flow

```
each host
  node_exporter (systemd collector) ──scrape── vmagent ──remoteWrite──▶ VM @ pc, VM @ edger
  systemd-journal-upload ──▶ vlagent (local, /insert/journald) ──remoteWrite──▶ VL @ pc, VL @ edger
hub (pc, edger)
  victoriametrics  :8428  (vmui at /vmui)
  victorialogs     :9428  (UI at /select/vmui)
  MCP server(s) for agents
```

## Verified facts

- `vlagent` reuses `vlinsert.RequestHandler`, so it accepts `/insert/journald/` directly (source: VictoriaLogs v1.49 `app/vlagent/main.go`, `app/vlinsert/main.go`). `-remoteWrite.url` is repeatable with per-URL disk queues.
- nixpkgs `victorialogs` builds vlagent only with `withVlAgent = true` override; there is **no** NixOS module for vlagent → custom systemd unit.
- nixpkgs `services.vmagent` has a single `remoteWrite.url`; extra URLs via `extraArgs`.
- `services.journald.upload` exists (systemd-journal-upload, single URL → point at local vlagent).
- `mcp-grafana` is packaged; the official `mcp-victoriametrics` / `mcp-victorialogs` are **not** — need packaging.

## Children

See child beans for: shared monitoring module, hub, metrics agent, log shipping, MCP, and Grafana follow-up.
