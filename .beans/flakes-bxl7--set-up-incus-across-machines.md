---
# flakes-bxl7
title: Set up Incus across machines
status: completed
type: task
priority: normal
created_at: 2026-03-15T02:39:38Z
updated_at: 2026-03-15T03:43:52Z
order: c
---

Set up Incus (container/VM manager) across all machines.

## Tasks

- [x] Create `mixins/nixos/services/incus.nix` — Incus daemon with KVM, directory storage pool, NAT networking
- [x] Create `modules/home/packages/incus.nix` — Incus client package + fish completions
- [x] Create `mixins/home/settings/incus/edger.nix` — sample remote config for edger.yjpark.org
- [x] Include mixin in at least one NixOS host to test (edger)

## Decisions

- No multi-host clustering
- Both containers and VMs (KVM enabled)
- Directory-based storage pool
- No shell abbreviations for now
- macOS colima setup is a separate future task

## Reference

See `clarified/2026-03-15_setup-incus.md` for full clarification notes.

## Summary of Changes

- : Enables incus daemon with NAT bridge network (incusbr0), directory storage pool, KVM kernel modules, and adds yjpark to the incus-admin group
- : Installs incus client and sources fish completions via shellInit
- : Home activation script that registers edger.yjpark.org as an incus remote (idempotent, skips if already present; manual cert trust still needed)
- : Added incus service mixin to edger host
