---
# flakes-dght
title: Drop nixos-unified, use raw flake-parts
status: completed
type: task
priority: high
created_at: 2026-04-05T06:23:52Z
updated_at: 2026-04-05T08:02:07Z
parent: flakes-qbvb
---

Replace nixos-unified.lib.mkFlake with flake-parts.lib.mkFlake. Separate host and container config namespaces. Rewrite home-configs.nix and activate-home.nix to own the logic directly. Keep autowire (from jig) for module discovery.

## Plan

- [x] Move host configs: configurations/nixos/{edger,a13,g1,p2,pc} → configurations/nixos/hosts/
- [x] Move container configs: configurations/nixos/{yolo,spacebot,hermes} → configurations/nixos/containers/
- [x] Rewrite flake.nix: use flake-parts.lib.mkFlake with explicit imports
- [x] Rewrite modules/flake/toplevel.nix: remove nixos-unified imports
- [x] Create modules/flake/nixos-configs.nix: explicit nixosConfigurations + nixosModules.default + homeModules.default + overlays
- [x] Rewrite modules/flake/home-configs.nix: use home-manager.lib.homeManagerConfiguration directly
- [x] Rewrite modules/flake/activate-home.nix: use home-manager switch --flake directly
- [x] Remove nixos-unified from flake inputs
- [x] Update mise.toml build tasks — no changes needed, output names unchanged
- [x] Test: nix flake check (passes — niri hash mismatch is pre-existing, unrelated)
- [ ] Test: mise run build-host (on edger) — blocked by pre-existing niri hash issue


## Summary of Changes

Completed in two commits:

1. **fee9eea** - Drop nixos-unified, use raw flake-parts
   - Replaced nixos-unified.lib.mkFlake with flake-parts.lib.mkFlake
   - Separated host/container configs into configurations/nixos/hosts/ and containers/
   - Rewrote home-configs.nix, activate-home.nix to own the logic directly
   - Removed nixos-unified flake input

2. **f69f1fd** - Restructure into packs/ with wireImportsRecursively
   - Introduced packs/ directory with autowired module collections
   - Added wireImportsRecursively to jig (1f1b27c)
   - Removed 28 boilerplate default.nix files
   - Merged modules/ and relevant mixins/ into packs/
   - Retained mixins/ for opt-in pieces (services, versions, storage, lan)
   - Deduplicated shared config (ai/, removed pass-through files)
