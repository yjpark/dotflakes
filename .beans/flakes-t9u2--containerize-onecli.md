---
# flakes-t9u2
title: Containerize OneCLI
status: completed
type: task
priority: normal
created_at: 2026-04-05T06:23:58Z
updated_at: 2026-04-05T12:38:34Z
parent: flakes-qbvb
---

Move OneCLI + postgres from podman-on-host to a dedicated incus container at 10.100.0.2. Update seeder to target container IP. Convert to NixOS service with local postgres (no more podman-in-podman).

## Summary of Changes

- Created `nixos/containers/onecli/` with NixOS config:
  - Static IP 10.100.0.2, native postgresql, podman onecli image with --network=host
  - Selective imports (skips ingress.nix and onecli-proxy.nix)
- Registered "onecli" in `flake/nixos-configs.nix`
- Updated `mixins/nixos/services/onecli.nix`: removed podman setup, now just the seeder pointing to 10.100.0.2
- Updated `packs/nixos/container/onecli-proxy.nix`: reference 10.100.0.2
- Updated all launch/utility scripts: spacebot .102→.101, hermes .103→.102, ubuntu .101→.200, onecli scripts 10.100.0.1→10.100.0.2
- Rewrote `onecli-reset-db.bash` to use incus exec instead of podman
- Added `incus-launch-onecli.bash`
