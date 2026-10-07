---
# flakes-dbiv
title: 'Monitoring: optional Grafana dashboards'
status: todo
type: feature
priority: deferred
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
parent: flakes-f2ju
blocked_by:
    - flakes-c6gm
    - flakes-m1as
---

Optional richer dashboards once the built-in vmui/VL UIs feel limiting.

## Spec

- `services.grafana` on hub(s), declaratively provisioned datasources: VictoriaMetrics (Prometheus type or VM plugin) and VictoriaLogs (`victoriametrics-logs-datasource` plugin).
- Provision Node Exporter Full dashboard + a per-host overview.
- Consider `mcp-grafana` (packaged in nixpkgs) as an alternative agent surface.
- Zerotier-only, same as the rest.

## Todo

- [ ] Grafana with provisioned datasources + dashboards
