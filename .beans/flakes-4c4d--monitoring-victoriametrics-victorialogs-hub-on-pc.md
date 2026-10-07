---
# flakes-4c4d
title: 'Monitoring: VictoriaMetrics + VictoriaLogs hub on pc and edger'
status: todo
type: task
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
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

- [ ] Enable VM + VL behind `monitoring.role.hub`
- [ ] Set role on pc and edger
- [ ] Verify both UIs reachable from the other host over zerotier
