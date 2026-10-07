---
# flakes-2gf7
title: 'Monitoring: shared topology module (hubs, roles, ports)'
status: todo
type: task
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
parent: flakes-f2ju
---

Shared NixOS module that defines the monitoring topology once, in the style of `mixins/nixos/lan/site.nix`, so hubs/agents derive their config from data instead of per-host copy-paste.

## Spec

- Location: `mixins/nixos/services/monitoring/` (opt-in mixin, imported by pc and edger `imports.nix`).
- Options (sketch):
  - `monitoring.hubs` — attrset of hub name → address, default `{ pc = "pc.yjpark.zerotier"; edger = "edger.yjpark.zerotier"; }` (zerotier names resolve/route from every site).
  - `monitoring.role.hub` — bool; enables VM + VL on this host (see hub bean).
  - `monitoring.role.agent` — bool, default true when the mixin is imported.
  - Ports as constants/options: VM 8428, VL 9428, node_exporter 9100, vlagent listen 9429 (localhost).
- Derived: list of VM remote-write URLs (`http://<hub>:8428/api/v1/write`) and VL remote-write URLs (`http://<hub>:9428/internal/insert`) for all hubs — confirm the exact vlagent→VL ingestion path from VictoriaLogs docs/source.
- Common labels: `host = config.networking.hostName`, `site = config.site.id`.

## Todo

- [ ] Create mixin with options + derived URL lists
- [ ] Import in `nixos/hosts/pc/imports.nix` and `nixos/hosts/edger/imports.nix`
- [ ] `mise run build-host` builds on both
