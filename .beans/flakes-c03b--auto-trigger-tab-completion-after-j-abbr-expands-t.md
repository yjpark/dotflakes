---
# flakes-c03b
title: Auto-trigger tab completion after j abbr expands to mise run _
status: completed
type: task
priority: normal
created_at: 2026-03-20T16:34:35Z
updated_at: 2026-03-20T16:35:07Z
---

Replace _j_abbr function with _j_expand fish function that handles expansion and triggers completion automatically when in a mise directory. Bind Space to _j_expand.

## Summary of Changes

- Removed  abbreviation entry from  (was using  function)
- Replaced  function with  in : detects when command line is exactly , expands to  + triggers completion in mise dirs, or  otherwise; falls through to normal space + abbr expansion for any other input
- Added  to bind Space to  (both normal and insert/vi mode)
