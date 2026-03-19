---
# flakes-vaiq
title: Dynamic per-host Home Manager configs via flake module
status: completed
type: task
priority: normal
created_at: 2026-03-15T04:46:11Z
updated_at: 2026-03-17T15:28:05Z
order: o
---

Create home-hosts.nix flake module to auto-generate homeConfigurations for all NixOS hosts, with optional host mixins. Delete per-host config files.

## Summary of Changes

- Created `modules/flake/home-hosts.nix`: dynamically generates homeConfigurations for all NixOS hosts by reading `configurations/nixos/` dirs, with optional per-host mixins from `mixins/home/hosts/<host>.nix`
- Created `mixins/home/hosts/gpd-p2.nix`: imports incus/edger mixin only for gpd-p2
- Updated `modules/flake/activate-home.nix`: adds fallback to plain `yjpark` config when hostname isn't in known NixOS hosts
- Deleted all per-host `configurations/home/yjpark@<host>.nix` files (pc, edger, alienware-13, hp-g1, gpd-p2)
- Key fix: used `lib.mkForce` on whole `legacyPackages` attrset (not just homeConfigurations sub-key) to override autoWire's perSystem definition
