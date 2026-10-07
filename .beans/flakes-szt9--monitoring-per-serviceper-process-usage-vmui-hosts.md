---
# flakes-szt9
title: 'Monitoring: per-service/per-process usage + vmui Hosts dashboard'
status: completed
type: feature
priority: normal
created_at: 2026-10-07T14:38:50Z
updated_at: 2026-10-07T15:02:07Z
parent: flakes-f2ju
blocked_by:
    - flakes-c6gm
---

Per-service and per-process resource usage (top/atop-style, over time), plus a host overview dashboard in vmui.

## Spec

### Exporters (agent.nix, every agent host)

- `services.prometheus.exporters.systemd`: per-unit CPU / memory / IO / restarts. Bind 127.0.0.1, add scrape job (instance relabelled to hostname like the others).
- `services.prometheus.exporters.process`: group by **command name** (`{{.Comm}}`), never per-PID — bounded cardinality. Bind 127.0.0.1, add scrape job.
- Add ports to `monitoring.ports` (defaults from the exporters: systemd 9558, process 9256).
- Check series counts per host after rollout; trim collectors if one dominates.

### vmui "Hosts" dashboard (hub.nix)

- VictoriaMetrics `-vmui.customDashboardsPath=<store path>` (flag present in 1.139; format: VictoriaMetrics repo `app/vmui/packages/vmui/public/dashboards`).
- Generate the JSON from Nix (`builtins.toJSON`) so it lives with the module.
- Panels: up per host, CPU %, memory %, disk % per mount, network rx/tx, load5, failed units, top-10 services by CPU/mem (systemd exporter), top-10 process groups by CPU/mem (process exporter).

### Out of scope

- `programs.atop` per-PID history (forensic replay via `atop -r`) — only if the 30s-resolution view proves insufficient.

## Todo

- [x] ~~systemd exporter + scrape job~~ dropped: systemd_exporter 0.7 no longer exports per-unit CPU/memory (only state/restarts/sockets, already covered by node_exporter systemd collector). Per-service usage comes from process-exporter grouped by cgroup instead.
- [x] process exporter + scrape job — groupname `{{.Comm}}|{{.Cgroups}}`, vmagent splits into `comm`, `cgroup`, `unit` labels; covers systemd units, incus containers (lxc.payload.*) and k3s pods. -threads=false, -gather-smaps=false; runs unprivileged so no per-process io.
- [x] Verify on pc and edger; note series counts — process job: edger ~2.6k, pc ~2.2k series
- [x] vmui custom dashboards (dashboards.nix): "Hosts overview" + one "Host: <name>" per `monitoring.hosts` (vmui has no template variables)
- [x] Verify dashboard renders on both hubs (custom-dashboards endpoint serves all 3 on pc and edger; every panel query returns data)

## Notes

- 2026-10-07 pc: ~2.4k process series; every dashboard panel query returns data on the pc hub.
- New option `monitoring.hosts` (default: hub names) lists agent hosts for per-host dashboards.

## Summary of Changes

- process-exporter grouped by `{{.Comm}}|{{.Cgroups}}`, split by vmagent into comm/cgroup/unit labels → top processes and per-service/container/pod usage.
- systemd_exporter dropped (no per-unit CPU/mem in 0.7).
- `dashboards.nix`: vmui Hosts overview + per-host dashboards from `monitoring.hosts`.
- Surfaced: greetd.service failed on both pc and edger.
