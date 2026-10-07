---
# flakes-me6e
title: 'Monitoring: vmalert health rules (per-site, no double alerts)'
status: todo
type: task
priority: low
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
parent: flakes-f2ju
blocked_by:
    - flakes-c6gm
---

Health rules on top of the metrics — deferred until the base pipeline is in.

## Spec

- `services.vmalert` on each hub, evaluating only its **own site's** hosts (filter by `site` label) to avoid double alerts from replicated data.
- Starter rules: host down (`up == 0`), any `node_systemd_unit_state{state="failed"} == 1`, disk > 85%, memory pressure, clock skew.
- Notifier: TBD (ntfy? existing channel?) — decide before implementing.

## Todo

- [ ] Decide notification target
- [ ] vmalert per hub with site filter + starter rules
