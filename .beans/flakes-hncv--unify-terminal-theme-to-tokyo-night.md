---
# flakes-hncv
title: Unify terminal theme to Tokyo Night
status: completed
type: task
priority: normal
created_at: 2026-03-27T10:40:30Z
updated_at: 2026-03-27T10:40:50Z
---

Switch wezterm from Gruvbox Dark to Tokyo Night theme, and update Zellij pane background color palette from Gruvbox-adjacent tints to Tokyo Night-adjacent tints. Kitty already uses tokyo_night_night.

## Summary of Changes

- **wezterm**: Changed `color_scheme` from `Gruvbox Dark (Gogh)` to `Tokyo Night` in `mixins/home/gui/linux/wezterm/wezterm.lua`
- **Zellij pane colors**: Updated palette in `modules/home/programs/fish/init/zellij.fish` from Gruvbox-adjacent tints (base `#282828`) to Tokyo Night-adjacent tints (base `#1a1b26`)

All terminal themes now unified on Tokyo Night: kitty (`tokyo_night_night`), wezterm (`Tokyo Night`), Zellij (`tokyo-night-dark`), and pane background tints.
