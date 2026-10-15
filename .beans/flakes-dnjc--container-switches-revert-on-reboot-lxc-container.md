---
# flakes-dnjc
title: Container switches revert on reboot (lxc-container module missing)
status: completed
type: bug
priority: high
created_at: 2026-10-15T13:41:37Z
updated_at: 2026-10-15T13:47:04Z
---

nixosConfigurations.<container> lacks nixpkgs virtualisation/lxc-container.nix (only added by build-image --image-variant lxc), so switch-to-configuration never repoints /sbin/init. After a restart the container boots the original image system and re-registers it as the newest generation. Hit when onecli was restarted after an in-place switch (flakes-i9ao).

- [x] Import lxc-container.nix from packs/nixos/container
- [x] Redeploy onecli and yolo with the lxc-capable toplevel
- [x] Verify /sbin/init points at the new system and survives incus restart

## Summary of Changes

`packs/nixos/container/configuration.nix` now imports `modulesPath + /virtualisation/lxc-container.nix`, so every container toplevel is the `-lxc` variant and its `installBootLoader` repoints `/sbin/init` on switch. `build-image --image-variant lxc` still evaluates (same module path, deduplicated). Redeployed onecli and yolo; `incus restart onecli` came back on the new system. yolo was switched but not restarted (its `/sbin/init` points at the new system).
