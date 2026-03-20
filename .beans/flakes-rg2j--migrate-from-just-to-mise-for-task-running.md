---
# flakes-rg2j
title: Migrate from just to mise for task running
status: completed
type: task
priority: normal
created_at: 2026-03-20T03:08:14Z
updated_at: 2026-03-20T03:09:04Z
---

Add mise.toml files and shell abbreviations to migrate task running from just to mise. Keep justfiles intact during transition.

## Summary of Changes

- Created  at repo root with all 12 tasks from the main justfile
- Created  with  task
- Created  with 4 preset tasks (update-presets + 3 individual)
- Added  and  abbreviations to fish () and nushell ()
- Justified files remain intact for the transition period
- All tasks verified working via `mise tasks` and `mise run vcs-status`
