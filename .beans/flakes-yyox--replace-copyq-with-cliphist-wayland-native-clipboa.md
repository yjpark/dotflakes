---
# flakes-yyox
title: Replace CopyQ with cliphist (Wayland-native clipboard manager)
status: completed
type: task
priority: normal
created_at: 2026-03-20T05:35:01Z
updated_at: 2026-03-20T05:35:42Z
---

Replace CopyQ (XWayland) with cliphist for Wayland-native clipboard history. Adds fuzzel picker keybinding, television cable channel, and fish function.

## Summary of Changes

- Deleted `mixins/home/gui/linux/services/copyq.nix` (removed CopyQ with forceXWayland)
- Created `mixins/home/gui/linux/services/cliphist.nix` (enables cliphist service)
- Added `Mod+V` keybinding in niri config to open fuzzel clipboard history picker
- Added `xdg.configFile` for television cable channel in `modules/home/programs/television.nix`
- Created `modules/home/programs/fish/functions/clip.fish` for tv-based clipboard selection
- Added `tc` abbreviation in `modules/home/programs/fish/abbrs.nix`
