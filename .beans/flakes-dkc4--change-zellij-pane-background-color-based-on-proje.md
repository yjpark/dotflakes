---
# flakes-dkc4
title: Change Zellij pane background color based on project path
status: completed
type: feature
priority: normal
created_at: 2026-03-27T07:27:24Z
updated_at: 2026-03-27T08:01:25Z
---

Visually distinguish panes belonging to different projects by assigning each project a unique background color in Zellij. Builds on the project-wise pane naming from flakes-1zlj.

## Design

### Palette

8 subtle Gruvbox-adjacent background tints (base bg is `#282828`):

| Index | Hex | Tint |
|-------|-----|------|
| 0 | `#2e1a1a` | Red |
| 1 | `#1a2e1a` | Green |
| 2 | `#1a1a2e` | Blue |
| 3 | `#2e2e1a` | Yellow |
| 4 | `#2e1a2e` | Magenta |
| 5 | `#1a2e2e` | Cyan |
| 6 | `#2e241a` | Orange |
| 7 | `#1a2e24` | Teal |

### Color Assignment

- Hash project name (simple checksum) mod palette size → deterministic color index
- Same project always gets the same color
- Known limitation: hash collisions possible, acceptable for now

### Behavior

- Home project (`ZELLIJ_SESSION_PROJECT`): no color change, stays at terminal default
- Foreign project: apply palette color via `zellij action set-pane-color --bg`
- On return to home project: `zellij action set-pane-color --reset`
- Applied on PWD change and shell init

### Files Changed

`modules/home/programs/fish/init/zellij.fish` only.

## Tasks

- [x] Add color palette array
- [x] Add hash function for project name → palette index
- [x] Add `zellij_update_pane_color` function
- [x] Integrate into PWD hook and init block
- [x] Reset color when returning to home project

## Summary of Changes

Added to `modules/home/programs/fish/init/zellij.fish`:
- `ZELLIJ_PANE_COLORS`: 8 subtle Gruvbox-adjacent bg tints
- `zellij_project_color_index`: djb2-style hash mod palette size, returns stable integer index
- `zellij_update_pane_color`: applies color for foreign projects, resets for home project
- Called from PWD hook and init block alongside existing pane/tab name updates
