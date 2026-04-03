---
# flakes-d4np
title: Extract ingress hub scripts for Ubuntu compatibility
status: completed
type: feature
priority: normal
created_at: 2026-04-03T07:26:29Z
updated_at: 2026-04-03T07:37:47Z
---

Extract scripts from mixins/nixos/container/ingress.nix into standalone files under mixins/home/container/ingress/, refactor NixOS module to reference them, and add ubuntu-setup-ingress.bash for Ubuntu container support.

## Tasks

- [x] Extract hub-index.html from ingress.nix
- [x] Extract generate-ingress-config.bash
- [x] Extract ingress-sync-api.py
- [x] Extract ingress.bash (status script)
- [x] Extract ingress-sync.bash
- [x] Create mixins/home/container/ingress/default.nix (Nix packages)
- [x] Refactor mixins/nixos/container/ingress.nix to use shared scripts
- [x] Create ubuntu-setup-ingress.bash


## Summary of Changes

Extracted inline scripts from the NixOS module into standalone files:
- Scripts live in `mixins/home/container/ingress/` (source of truth)
- Copies in `mixins/nixos/container/ingress-scripts/` (needed due to Nix flake autowire boundaries)
- NixOS module refactored to use `builtins.readFile` on local copies
- Home Manager module adds scripts to PATH via `home.packages`
- `ubuntu-setup-ingress.bash` handles apt packages, systemd units, dnsmasq, resolved, sudo rules
- All three configs (yolo, yolo-lima, home/yj) evaluate successfully
