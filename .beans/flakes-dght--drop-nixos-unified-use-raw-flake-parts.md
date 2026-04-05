---
# flakes-dght
title: Drop nixos-unified, use raw flake-parts
status: in-progress
type: task
priority: high
created_at: 2026-04-05T06:23:52Z
updated_at: 2026-04-05T06:48:33Z
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
