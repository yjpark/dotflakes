---
# flakes-c6gm
title: 'Monitoring: node_exporter + vmagent dual-write on each host'
status: todo
type: task
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
parent: flakes-f2ju
blocked_by:
    - flakes-4c4d
---

Metrics agent on every monitored host, dual-writing to all hubs.

## Spec

- `services.prometheus.exporters.node`: enable `systemd` collector (unit active/failed state) plus defaults (cpu, mem, fs, net, hwmon, pressure). Listen on localhost only.
- `services.vmagent`: scrape local node_exporter (and VM/VL self-metrics on hubs); `remoteWrite.url` = first hub, remaining hubs via `extraArgs` `-remoteWrite.url=...` (nixpkgs module only takes one URL). Set `-remoteWrite.tmpDataPath` under the state dir so per-URL queues persist across restarts / link outages; set a sane `-remoteWrite.maxDiskUsagePerURL`.
- External labels: `host`, `site` (from shared module).
- Optional extra: smartctl exporter for disks (could be a follow-up).

## Todo

- [ ] node_exporter with systemd collector
- [ ] vmagent with all hub URLs + persistent queue
- [ ] Verify both hubs see `up{host="pc"}` and `up{host="edger"}`
- [ ] Verify buffering: stop VM on one hub, wait, restart, confirm no gap
