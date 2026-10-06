---
# flakes-wabt
title: 'pc: move /home to dedicated ext4 disk (nvme0n1)'
status: completed
type: task
priority: normal
created_at: 2026-10-06T14:52:35Z
updated_at: 2026-10-06T15:12:41Z
---

Wipe the SanDisk 1.8T NVMe (nvme0n1, formerly Windows/NTFS mounted manually at /data/win), format the whole disk as one ext4 partition, copy the current /home over, and declare fileSystems."/home" in nixos/hosts/pc/hardware-configuration.nix.

- [x] Unmount /data/win, wipe nvme0n1, single GPT partition, mkfs.ext4 -L home
- [x] Initial rsync of /home to new fs
- [x] Declare fileSystems."/home" in pc hardware-configuration.nix, build
- [x] Final rsync from TTY with user logged out, nixos-rebuild boot, reboot
- [x] Verify, then reclaim old /home space on root fs

## Summary of Changes

- Wiped the SanDisk 1.8T NVMe (old Windows/NTFS), one GPT partition, ext4 label `home`, UUID 7f0e17fa-9aa1-4124-ae43-0de24e743822.
- Added `fileSystems."/home"` (by-uuid) to `nixos/hosts/pc/hardware-configuration.nix`.
- Copied /home over, rebooted onto it, deleted the shadowed old /home on the root fs (~52G freed).
- Note: NVMe kernel names swapped after reboot (root is now nvme0n1p2, home nvme1n1p1); config uses UUIDs so this is harmless.
