---
# flakes-y887
title: Add rtk-rewrite.sh hook to claude module with home-manager linking
status: completed
type: task
priority: normal
created_at: 2026-03-23T04:52:54Z
updated_at: 2026-03-23T07:48:19Z
order: s
---

Add the rtk-rewrite.sh hook file to modules/home/programs/claude/hooks/ and set up home.file linking to ~/.claude/hooks/rtk-rewrite.sh

## Summary of Changes

- Created `modules/home/programs/claude/hooks/rtk-rewrite.sh` (copied from `~/.claude/hooks/rtk-rewrite.sh`)
- Created `modules/home/programs/claude/hooks/default.nix` linking it to `~/.claude/hooks/rtk-rewrite.sh` with executable=true
- Autowire in `claude/default.nix` picks up the new hooks/ subdirectory automatically — no other files changed
