---
# flakes-1zlj
title: Project-wise pane configuration in Zellij
status: completed
type: feature
priority: normal
created_at: 2026-03-27T06:26:31Z
updated_at: 2026-03-27T07:27:17Z
---

Configure Zellij pane/tab naming to visually identify projects in multi-project sessions.

## Design

### State Management

- **State file**: `/tmp/zellij-tab-{ZELLIJ_SESSION_NAME}` — one line per pane: `{PANE_ID}={project_name}`
- **Session root**: Capture `$PWD` at shell init as `ZELLIJ_SESSION_PROJECT` — the "home" project for the session
- **Project name**: Git repo root basename (`git rev-parse --show-toplevel | basename`), fallback to `basename $PWD`

### Pane Name Behavior

| Condition | Pane name |
|-----------|-----------|
| PWD is within session's starting project | `{command}` (current behavior) |
| PWD is in a different project | `<{project}> {command}` |
| Idle (no running command) | `<{project}>` or empty (current behavior) |

Updated in `fish_preexec` (command starts) and on `PWD` change.

### Tab Name Behavior

On every `PWD` change in any pane:
1. Write/update own entry in the state file
2. Read all entries, collect unique project names
3. If only one unique project: `rename-tab "{project}"` (same as today)
4. If multiple: `rename-tab "{project1} | {project2} | ..."`

### Cleanup

- **`fish_exit` event**: Remove own pane entry from state file, rebuild tab name
- **Shell init**: Prune entries whose pane IDs are no longer in the state file

## Tasks

- [x] Add helper to resolve project name (git root basename, fallback to basename PWD)
- [x] Capture session project on shell init ($ZELLIJ_SESSION_PROJECT)
- [x] Implement state file writes (per-pane project tracking)
- [x] Update pane name logic: \<project\> command format when outside session project
- [x] Update tab name logic: aggregate unique projects from state file
- [x] Add cleanup on fish_exit
- [x] Add stale entry pruning on shell init (simplified: natural overwrite on pane ID reuse)

## Summary of Changes

Implemented in `modules/home/programs/fish/init/zellij.fish`:
- `zellij_project_name`: resolves git repo root basename, fallback to basename PWD
- `ZELLIJ_SESSION_PROJECT`: captured at shell init to detect foreign projects
- State file (`/tmp/zellij-tab-{SESSION}`): per-pane project tracking, scoped by session name
- Pane names: `<project> command` when in foreign project, just `command` otherwise
- Tab names: aggregated unique projects in pane order, joined with ` | `
- Cleanup on `fish_exit` removes pane entry and rebuilds tab name
