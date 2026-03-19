---
# flakes-7aac
title: Resolve username from host/container dir in activate-home.nix
status: completed
type: task
priority: normal
created_at: 2026-03-19T16:48:11Z
updated_at: 2026-03-19T16:48:44Z
---

Replace flat knownHosts list with separate hosts/containers lists so activate-home.nix determines username (yjpark vs yj) from which dir the hostname is found in, rather than using $(id -un). Also update home-configs.nix fallback key to use 'username@' format.

## Summary of Changes

- : replaced flat `knownHosts` with separate `hosts` and `containers` lists; shell script now checks hosts first (→ `yjpark@$_host`), then containers (→ `yj@$_host`), falling back to `$(id -un)@` only when hostname is unknown
- `home-configs.nix`: updated fallback key from `${username}` to `"${username}@"` to match new shell script format
