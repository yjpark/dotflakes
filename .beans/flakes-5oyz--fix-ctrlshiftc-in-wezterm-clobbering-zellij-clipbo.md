---
# flakes-5oyz
title: Fix Ctrl+Shift+C in wezterm clobbering zellij clipboard
status: completed
type: bug
priority: normal
created_at: 2026-03-20T05:12:34Z
updated_at: 2026-03-20T05:12:43Z
---

Copy (to system clipboard) doesn't work when using wezterm → incus shell → zellij. Root cause: Ctrl+Shift+C runs CopyTo('Clipboard') which copies empty terminal selection, overwriting what zellij put in clipboard via OSC 52. Fix: only copy when there's an actual selection.

## Summary of Changes

Changed  binding in  from a direct  action to a callback that first checks if there's an actual terminal selection. Only copies when selection is non-empty, matching kitty's behavior and preventing the clipboard from being clobbered when zellij has already set it via OSC 52.
