---
# flakes-p2qs
title: 'Niri config: declarative host-based mixin'
status: completed
type: feature
priority: normal
created_at: 2026-03-20T06:01:31Z
updated_at: 2026-03-20T06:16:13Z
---

Make niri KDL config fully declarative by moving host-specific extras into per-host mixins, eliminating the manual apply-extras step.

## Summary of Changes

- Added `me.niri.extraConfig` option to `modules/home/options.nix`
- Updated `modules/flake/home-configs.nix` to support directory-based host mixins (falls back to `/{host}.nix` if no directory exists)
- Created `mixins/home/hosts/a13/` and `mixins/home/hosts/edger/` with `default.nix` + `niri.extras.kdl`
- Rewrote niri config module to concatenate `config.common.kdl` + `config.me.niri.extraConfig`
- Deleted `extras.a13.kdl`, `extras.edger.kdl`, and `niri.justfile` from old location
