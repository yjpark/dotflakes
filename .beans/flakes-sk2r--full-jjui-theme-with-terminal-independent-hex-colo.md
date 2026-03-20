---
# flakes-sk2r
title: Full jjui theme with terminal-independent hex colors
status: completed
type: task
priority: normal
created_at: 2026-03-20T07:44:59Z
updated_at: 2026-03-20T07:46:48Z
---

Replace the partial Pencil Dark fix with a complete theme using only hex/ANSI256 colors (no ANSI 0-15) so it looks good on any dark terminal.

## Summary of Changes

Replaced partial Pencil Dark fix with a complete One Dark-inspired theme in `modules/home/programs/jujutsu.nix`. Covers all 60+ color keys: core, flash, confirmation, help, revisions list/details, revset/completion, status, menu, picker, oplog, evolog, rebase/squash/duplicate/revert/set_parents, input, choose. All colors use explicit hex values — no ANSI 0-15 — so the theme is terminal-agnostic.
