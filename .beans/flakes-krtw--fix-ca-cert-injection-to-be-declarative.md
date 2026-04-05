---
# flakes-krtw
title: Fix CA cert injection to be declarative
status: completed
type: task
priority: normal
created_at: 2026-04-05T06:23:54Z
updated_at: 2026-04-05T13:13:14Z
parent: flakes-qbvb
---

Replace manual /etc/ssl/certs mutation with security.pki.certificateFiles. Seeder pushes CA to a known path, NixOS handles cert bundle integration.

## Summary of Changes

- `packs/nixos/container/onecli-proxy.nix`: added `/var/lib/onecli/` tmpfiles dir, `onecli-ca-bundle.service` (oneshot, rebuilds bundle idempotently from system certs + CA), and `onecli-ca-bundle.path` (watches `/var/lib/onecli/ca.crt`, re-triggers on every push/rotation). Updated `NODE_EXTRA_CA_CERTS` to point to the new stable path.
- `mixins/nixos/services/onecli.nix`: seeder now writes CA to `/var/lib/onecli/ca.crt` only — no more in-container symlink replacement or bundle appending.
- `packs/home/host/linux/scripts/incus/onecli-push-ca.bash`: same simplification.
