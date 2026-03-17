---
provider: beans
type: task
title: "Fix terminal tab title when running zellij"
date: 2026-03-17
status: organized
source: beans://flakes-2fpy
bean_id: flakes-2fpy
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
