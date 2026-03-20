---
# flakes-m3r8
title: Fix mise.toml var args bug
status: completed
type: bug
priority: normal
created_at: 2026-03-20T03:30:52Z
updated_at: 2026-03-20T03:31:07Z
---

Remove unused args and fix the var=true arg to be optional (default='') in mise.toml

## Summary of Changes

- : removed unused  — task never needed extra args
- : changed  to  so it's optional
- : removed unused trailing 
- : removed unused trailing 
