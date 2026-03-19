---
# flakes-rg27
title: Integrate Home Manager as a NixOS module
status: completed
type: task
priority: normal
created_at: 2026-03-15T05:31:36Z
updated_at: 2026-03-17T15:28:05Z
order: u
---

Create modules/nixos/settings/home-manager.nix to import home-manager as a NixOS module so nixos-rebuild switch handles both system and home config in one command.

## Summary of Changes

Created `modules/nixos/settings/home-manager.nix` which:
- Imports `home-manager.nixosModules.home-manager`
- Sets `useGlobalPkgs = true` and `useUserPackages = true`
- Passes `extraSpecialArgs` with the `flake` argument so home modules get their expected `{flake, ...}` argument
- Wires `home-manager.users.yjpark` to import `configurations/home/yjpark.nix` plus any host-specific mixin from `mixins/home/hosts/<hostname>.nix`

The module is auto-included in all NixOS hosts via the autowired `modules/nixos/settings/` directory. Verified with `nix flake check` and `just build-host` — home-manager generation is now built as part of the NixOS system build.
