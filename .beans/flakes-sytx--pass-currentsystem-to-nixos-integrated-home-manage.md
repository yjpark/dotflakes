---
# flakes-sytx
title: Pass currentSystem to NixOS-integrated home-manager extraSpecialArgs
status: completed
type: bug
priority: high
created_at: 2026-05-08T16:02:57Z
updated_at: 2026-05-08T16:03:48Z
---

nixos-rebuild on g1 fails with infinite recursion in packs/home/host because the NixOS-integrated home-manager module (packs/nixos/common/settings/home-manager.nix) doesn't pass currentSystem via extraSpecialArgs. Standalone home configurations get it via flake/home-configs.nix but NixOS hosts that use home-manager.users.* don't.

## Summary of Changes

Updated `packs/nixos/common/settings/home-manager.nix` to:
- Take `pkgs` as module argument
- Pass `currentSystem = pkgs.stdenv.hostPlatform.system` via `extraSpecialArgs`

This mirrors what `flake/home-configs.nix` already does for standalone home configurations. The integrated home-manager NixOS module evaluates `packs/home/host` (via `home/yjpark.nix` imported through `packs/nixos/host/yjpark.nix`), and that module reads `currentSystem` in its `imports` to conditionally include the linux subdirectory.

Verified: g1 evaluation now progresses past the recursion point (fails only on an unrelated network fetch of Smithay/smithay.git).
