---
# flakes-jkwu
title: 'wezterm: Claude Code editing ergonomics (shipped)'
status: completed
type: task
tags:
    - wezterm
created_at: 2026-06-29T14:03:47Z
updated_at: 2026-06-29T14:03:47Z
---

Two wezterm ergonomics tweaks for Claude Code, **already shipped** in `packs/home/gui/linux/wezterm/wezterm.lua`. Captured for the record.

## 1. Ctrl+\ → soft newline in Claude Code

Send `Space \ <50ms delay> Enter` so CC inserts a continuation line instead of submitting. The delay matters — without it a stray `\` is left on the last line.

```lua
{ key = '\\', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
    window:perform_action(act.SendKey { key = 'Space' }, pane)
    window:perform_action(act.SendKey { key = 'Backslash' }, pane)
    wezterm.sleep_ms(50)
    window:perform_action(act.SendKey { key = 'Enter' }, pane)
end)},
```

## 2. Don't let Ctrl+Shift+C clobber the zellij/OSC-52 clipboard

Through wezterm → remote shell → zellij, `Ctrl+Shift+C` ran `CopyTo('Clipboard')` which copied the (empty) *terminal* selection, overwriting what zellij had already put on the system clipboard via OSC 52. Fix: make the binding a callback that only copies when there is a non-empty terminal selection (mirrors kitty's behavior). Upstreamable.

## Status

Both bindings are present in `wezterm.lua` (lines ~60–74). This bean documents them; no further work unless upstreaming the Ctrl+Shift+C fix.

## Todo

- [x] Ctrl+\ soft-newline binding
- [x] Ctrl+Shift+C clipboard-safe binding
- [ ] (optional) Upstream the Ctrl+Shift+C selection-guard behavior to wezterm
