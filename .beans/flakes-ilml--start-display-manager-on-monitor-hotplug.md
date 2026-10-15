---
# flakes-ilml
title: Start display manager on monitor hotplug
status: completed
type: feature
priority: normal
created_at: 2026-10-15T16:07:51Z
updated_at: 2026-10-15T16:20:10Z
---

On headless edger cosmic-greeter exits with no connected outputs, greetd hits start-limit-hit, and nothing retries when a monitor is later plugged in. Add a udev DRM hotplug rule that (re)starts display-manager.service only when it is not already active.

- [x] Add packs/nixos/gui/display-manager-hotplug.nix
- [x] Switch edger and verify the rule/service
- [x] Commit and push

## Summary of Changes

Added `packs/nixos/gui/display-manager-hotplug.nix`: udev rules on DRM `change` events with `HOTPLUG=1` (real connector hotplug) or `SYNTH_ARG_HOTPLUG=1` (manual synthetic test) start a oneshot that resets and starts `display-manager.service` only when it is not active.

Verified on edger with a synthetic uevent (`echo "change <uuid> HOTPLUG=1" > /sys/class/drm/card1/uevent`): greetd went from failed to started, then hit its start limit again with no monitor attached. The greeter itself emits synthetic change events without the hotplug arg, so there is no feedback loop. Note `udevadm trigger -p HOTPLUG=1` is rejected by the kernel (-EINVAL), and writes from the Claude sandbox shell did not reach the kernel; use systemd-run or a real shell.

A real monitor plug-in was not tested (edger has none attached).
