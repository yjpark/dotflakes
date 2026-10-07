---
# flakes-4c4d
title: 'Monitoring: VictoriaMetrics + VictoriaLogs hub on pc and edger'
status: in-progress
type: task
priority: normal
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T14:20:03Z
parent: flakes-f2ju
blocked_by:
    - flakes-2gf7
---

Run the storage + UI on each hub (pc, edger) when `monitoring.role.hub = true`.

## Spec

- `services.victoriametrics`: listen `:8428`, retention ~90d (tune), vmui at `/vmui`.
- `services.victorialogs`: listen `:9428`, retention ~30d (tune), UI at `/select/vmui`.
- Access via zerotier only: zerotier is in firewalld `trusted`, so no new firewall rules; do **not** add the ports to `lan`/public zones. Verify reachability from the other site.
- Disk: check free space on pc (`/` ext4, `/home` dedicated disk) and edger; pick `stateDir` accordingly.
- Note: edger is on `versions/22.05.nix` stateVersion — module is fine, but confirm no stateVersion-gated defaults bite.

## Todo

- [x] Enable VM + VL behind `monitoring.role.hub` (mixins/nixos/services/monitoring/hub.nix; VM 90d, VL 30d capped at 20GiB; pc build OK, adds only VM/VL)
- [x] Set role on pc and edger (automatic: role.hub defaults to membership in monitoring.hubs)
- [ ] Verify both UIs reachable from the other host over zerotier

## Notes

- 2026-10-07: edger (172.22.1.2) unreachable over zerotier from pc (ping 100% loss) — cross-site check pending until it is back.
- Disk: pc / has 128G free (state lives under /var/lib/private on /). edger disk not checked yet (unreachable); VL capped at 20GiB via -retention.maxDiskSpaceUsageBytes.
- lan zone already admits the site /24 on all ports, so hub UIs are reachable from the local site LAN as well as zerotier.

- 2026-10-07: pc switched; VM/VL /health, /vmui, /select/vmui all 200 locally and from edger over zerotier. Interactive shells with http_proxy and no no_proxy get 502 from clash — use --noproxy or bypass .yjpark.zerotier; system services are unaffected (cn/proxy-env only proxies nix-daemon/k3s/containerd).
- edger disk: / 1.8T, 186G free (89% used) — 20GiB VL cap is fine.
