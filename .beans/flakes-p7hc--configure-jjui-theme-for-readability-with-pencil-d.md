---
# flakes-p7hc
title: Configure jjui theme for readability with Pencil Dark terminal theme
status: completed
type: task
priority: normal
created_at: 2026-03-20T07:28:26Z
updated_at: 2026-03-20T07:29:37Z
---

Add settings.ui.colors overrides to programs.jjui in modules/home/programs/jujutsu.nix to fix readability issues with the Pencil Dark (Gogh) WezTerm color scheme. The default dark theme uses 'bright black' for dimmed text and selected backgrounds, which is too dark/invisible in Pencil Dark.

## Summary of Changes

Added `settings.ui.colors` overrides to `programs.jjui` block in `modules/home/programs/jujutsu.nix`. Key fixes:
- `dimmed`: `"bright black"` → `"#808080"` (mid-gray, readable in Pencil Dark)
- `selected` / `revisions details selected` bg: `"bright black"` → `"#3a3a3a"`
- `revset completion` bg: `"black"` → `"#1a1a1a"`
- `revset completion dimmed`: same fix as `dimmed`

Config verified at `~/.config/jjui/config.toml` after `just activate-home`.
