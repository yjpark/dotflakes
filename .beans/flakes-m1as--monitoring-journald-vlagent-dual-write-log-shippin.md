---
# flakes-m1as
title: 'Monitoring: journald → vlagent dual-write log shipping'
status: todo
type: task
created_at: 2026-10-07T13:39:28Z
updated_at: 2026-10-07T13:39:28Z
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

- [ ] vlagent package override + systemd unit
- [ ] journald upload → local vlagent
- [ ] Verify in both hub UIs: `_SYSTEMD_UNIT:sshd.service` from both hosts
- [ ] Verify buffering across a hub outage
