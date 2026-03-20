---
# flakes-0ycg
title: Create mise-run-or-just fish function
status: completed
type: task
priority: normal
created_at: 2026-03-20T15:59:26Z
updated_at: 2026-03-20T15:59:44Z
---

Create a fish wrapper function that auto-detects whether to use mise run or just based on whether mise is configured in the current directory. Update the j abbr to use it.

## Summary of Changes

- Created : wrapper that checks [
  {
    "path": "/home/yj/agents/flakes/mise.toml",
    "tools": []
  }
] output; if non-empty array, uses , otherwise falls back to 
- Updated  line 21:  → 
