---
# flakes-c6gm
title: 'Monitoring: node_exporter + vmagent dual-write on each host'
status: completed
type: task
priority: normal
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T15:02:07Z
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
- [x] vmagent with all hub URLs + persistent queue
- [x] Verify both hubs see `up{host="pc"}` and `up{host="edger"}`
- [x] Verify buffering — verified naturally: pc vmagent queued for edger ~30 min before edger hub existed; after edger came up it holds pc node samples from 14:28Z continuously (34 x 1m, no gap), queues drained to 0.

## Notes

- 2026-10-07: pc switched (mixins/nixos/services/monitoring/agent.nix). pc hub has up{host="pc"} for node/vmagent/victoriametrics/victorialogs, 870 node_systemd_unit_state series. Already surfaced: greetd.service failed on pc.
- instance relabelled to hostname (scrape address is 127.0.0.1 on every host). external_labels host/site from monitoring.labels.
- Queue to edger retrying until edger's hub is deployed.

## Summary of Changes

- `mixins/nixos/services/monitoring/agent.nix`: node_exporter (systemd, processes collectors) and vmagent bound to localhost; vmagent writes to every hub URL with per-URL on-disk queues (1GB cap each), external labels host/site, instance relabelled to hostname. Hubs also scrape their own VM/VL.
- Deployed and verified on pc and edger: both hubs show 5 targets up per host.
