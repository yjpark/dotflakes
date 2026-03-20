---
# flakes-6n5b
title: Restructure home config host/container registration
status: completed
type: task
priority: normal
created_at: 2026-03-19T16:39:36Z
updated_at: 2026-03-20T05:24:41Z
order: z
---

Move host/container registration to mixins/home/hosts/ and mixins/home/containers/, update home-configs.nix and activate-home.nix accordingly

## Summary of Changes

- Created  files for alienware-13, edger, hp-g1, pc (each imports 25.05 version mixin)
- Updated  to add 25.05 version import
- Created  importing 26.05 version mixin
- Deleted 
- Rewrote : removed `configDir` param, `mixinDir` now serves both roles
- Rewrote : reads host names from hosts/ and containers/ dirs; fixed fallback key (removed trailing @)
- Removed version imports from `configurations/home/yjpark.nix` and `configurations/home/yj.nix`

Verified: `nix eval .#homeConfigurations --apply 'x: builtins.attrNames x'` returns expected keys.
