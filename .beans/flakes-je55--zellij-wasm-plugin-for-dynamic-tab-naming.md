---
# flakes-je55
title: Zellij WASM plugin for dynamic tab naming
status: draft
type: feature
created_at: 2026-03-27T12:41:47Z
updated_at: 2026-03-27T12:41:47Z
---

## Background

We implemented project-aware tab naming in Zellij via fish shell hooks. After extensive iteration, the current approach uses `zellij action dump-layout` to parse pane names in visual order and compose tab names (e.g., `flakes | litmus`).

### What works well (current fish implementation)
- Project detection via git root basename (`zellij_project_name`)
- Pane naming with `<project>` prefix (`zellij_update_panename`)
- Deterministic pane background colors per project (`zellij_update_pane_color`)
- Tab name composed from unique project names in visual order (`zellij_visual_projects`)
- `dump-layout` parsing gives correct visual order and avoids state file race conditions

### Remaining trigger limitations (fish shell can't solve)
- **Pane moves between tabs**: no fish event fires when a pane is moved — tab name only updates on next `cd`
- **Pane detach/reattach**: splitting a pane into a new tab doesn't trigger any shell hook
- **Non-shell panes**: panes running editors, Claude, or other long-running processes never return to fish prompt
- **All-tab updates**: when a pane moves, both source and destination tabs need updating — fish can only rename the current tab

### Why a WASM plugin is the right approach
- Zellij plugins receive native events: `TabUpdate`, `PaneUpdate`, `ModeUpdate`
- A plugin can react to pane moves, tab changes, and layout changes in real-time
- It can update ALL tab names (not just the focused tab) via `rename_tab`
- No shell hooks needed for tab naming — the plugin handles it entirely
- Fish hooks can focus solely on pane-level concerns (pane name, pane color)

### Design considerations
- [ ] Research Zellij plugin API for tab/pane events
- [ ] Determine how to detect pane project (read pane name set by fish, or query cwd?)
- [ ] Prototype plugin that listens to layout changes and renames tabs
- [ ] Decide whether to keep fish-based pane naming or move everything to the plugin
- [ ] Package the plugin with Nix

### Reference
- Zellij plugin docs: https://zellij.dev/documentation/plugins
- Current fish implementation: `modules/home/programs/fish/init/zellij.fish`
- Tab bar plugin already in use: `~/.config/zellij/plugins/tab-bar.wasm`
