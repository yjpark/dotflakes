---
# flakes-5pbu
title: Remove stateVersion mixin pattern, use defaults instead
status: completed
type: task
priority: normal
created_at: 2026-03-19T17:08:13Z
updated_at: 2026-03-20T05:24:41Z
order: w
---

Set default stateVersion in base configs, delete nearly-empty mixin files, fix fallback key mismatch in activate-home.nix

## Summary of Changes

- Added `home.stateVersion = "25.05"` to `configurations/home/yjpark.nix`
- Added `home.stateVersion = "26.05"` to `configurations/home/yj.nix`
- Deleted nearly-empty host mixin files: alienware-13.nix, edger.nix, hp-g1.nix, pc.nix, and containers/yolo.nix
- Restored `mixins/home/containers/.gitkeep` for future use
- Simplified `mixins/home/hosts/gpd-p2.nix`: removed version import, kept only incus/edger.nix import
- No change needed to activate-home.nix (the trailing `@` on fallback key is required by nixos-unified; home-configs.nix omits it correctly as nixos-unified adds it internally)
