---
# flakes-2fpy
title: Tidy up the shell title when running zellij
status: completed
type: task
priority: normal
tags:
    - tweaks
created_at: 2026-03-14T01:38:54Z
updated_at: 2026-03-17T15:54:59Z
order: s
---

## Objective

Configure zellij so the terminal emulator's tab title (kitty/wezterm tab bar) shows the **zellij session name** instead of the verbose `<cwd> | <last command with args>` format zellij currently sets.

## Context

When zellij runs inside a kitty or wezterm tab, it overwrites the terminal's tab title with its own format: `<current directory> | <last command with arguments>`. This is too long for a tab bar and makes tabs hard to distinguish.

Fish shell's `fish_title` is already configured to show just the current directory or last command name, and works correctly when zellij is not running. The problem is specifically that zellij overrides the terminal title with its own verbose format.

## Requirements

- Configure zellij to set the terminal tab title to its session name (e.g. "main", "dev")
- Do not modify fish_title or other shell-level title configuration
- Zellij's internal pane/tab titles (within zellij's own UI) are out of scope and can remain as-is

## Acceptance Criteria

- When zellij is running in a kitty or wezterm tab, the tab bar shows the zellij session name
- When zellij is not running, fish_title continues to work as before (current directory or last command name)
- No regressions in zellij's internal tab/pane display

## Summary of Changes

- : Return empty string when inside zellij — zellij's `make_terminal_title` already shows just the session name, so an empty pane title avoids duplication (was: echo $ZELLIJ_SESSION_NAME which produced `.skills | .skills`)
- : Removed `zellij_update_tabname_pwd` (PWD event hook) and `zellij_update_panename_cmd` (preexec event hook) — these were driving zellij's verbose `<cwd> | <command>` terminal title format. Kept `zellij_update_tabname` call at startup only, which sets the zellij internal tab name to the initial directory once.

## Revision: New Approach (2026-03-17)

Previous approach (empty fish_title inside zellij) broke zellij's internal tab/pane renaming.

New approach: revert fish/zellij files to original, configure kitty and wezterm to extract just the session name (before ' | ') from the terminal title for display.

- [x] Revert fish_title.fish to original
- [x] Revert zellij.fish to original
- [x] Update kitty tab_title_template to use partition(' | ')[0]
- [x] Add wezterm format-tab-title event handler

## Summary of Revised Changes

- Reverted  to original (no ZELLIJ_SESSION_NAME check)
- Reverted  to original (restored  and  hooks)
- Updated kitty  to use  — strips  suffix, showing only the session name
- Added wezterm  event handler that extracts text before  using Lua pattern matching
