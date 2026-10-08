---
# flakes-m1as
title: 'Monitoring: journald → vlagent dual-write log shipping'
status: completed
type: task
priority: normal
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-08T06:56:40Z
parent: flakes-f2ju
blocked_by:
    - flakes-4c4d
---

Ship journald from every monitored host to all hubs.

## Spec

- Package: `pkgs.victorialogs.override { withVlAgent = true; withServer = false; }` (vlagent not built by default).
- Custom systemd unit `vlagent` (no NixOS module exists): `DynamicUser`, `StateDirectory`, listen `127.0.0.1:9429`, `-remoteWrite.url` once per hub, `-tmpDataPath` in state dir for per-URL persistent queues.
- `services.journald.upload`: `settings.Upload.URL = "http://127.0.0.1:9429/insert/journald"` (vlagent accepts the journald protocol via vlinsert handler — verified in v1.49 source).
- Stream fields: set `-journald.streamFields` (e.g. `_HOSTNAME,_SYSTEMD_UNIT,PRIORITY`) on the **hub VL** or vlagent — check which side applies them when forwarding.
- Add `host`/`site` fields if not already carried by `_HOSTNAME`.

## Todo

- [x] vlagent package override + systemd unit
- [x] journald upload → local vlagent
- [x] Verify in both hub UIs: `_SYSTEMD_UNIT:sshd.service` from both hosts
- [x] Verify buffering across a hub outage

## Summary of Changes

- `mixins/nixos/services/monitoring/logs.nix`: `systemd-journal-upload` → local `vlagent` (127.0.0.1:9429, built via `victorialogs.override { withVlAgent = true; }`, custom unit since there is no NixOS module) → every hub's VictoriaLogs, per-URL disk queue (1GB cap each).
- Hub ingest URL corrected to `/insert/native` (vlagent's documented endpoint; `/internal/insert` is the cluster-internal protocol).
- Stream fields: vlagent applies them itself; defaults `_MACHINE_ID,_HOSTNAME,_SYSTEMD_UNIT` kept. No extra host/site fields: `systemd-journal-upload` appends `/upload` to its URL so query-string extra fields are not an option, and `_HOSTNAME` already identifies the host.
- First-start backfill limited to the retention window: an `ExecStartPre` seeds the upload cursor at the last entry older than `monitoring.retention.logs` (30d), instead of pushing the full ~4G journal (back to May on pc) across sites only for hubs to discard it.
- Deployed on pc and edger (2026-10-08). Backfill finished in ~90s: both hubs hold edger ≈7.3M and pc ≈3.3M entries for 30d; ~138M on disk per hub.
- Verified: `_SYSTEMD_UNIT:sshd.service` returns both hosts on both hubs; buffering — stopped edger's VictoriaLogs, logged a marker on pc (vlagent retried), restarted, marker reached edger ~6s later.
