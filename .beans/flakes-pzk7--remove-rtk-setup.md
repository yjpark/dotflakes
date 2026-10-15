---
# flakes-pzk7
title: Remove rtk setup
status: completed
type: task
priority: normal
created_at: 2026-10-15T13:41:37Z
updated_at: 2026-10-15T13:47:04Z
---

Remove rtk entirely: package, init script, Claude Code PreToolUse rewrite hook and its settings.json entry.

- [x] Drop llm-agents.rtk from packs/home/common/ai/llm-agents.nix
- [x] Delete packs/home/common/ai/init/rtk-init.bash
- [x] Delete packs/home/common/programs/claude/hooks/rtk-rewrite.sh and the hook entry in files/settings.json
- [x] Build check

## Summary of Changes

Removed `llm-agents.rtk`, `rtk-init.bash`, the whole `programs/claude/hooks/` dir (it existed only to link rtk-rewrite.sh), and the PreToolUse hook from `files/settings.json`. Applied on edger (home) and yolo (system switch); also deleted leftover `~/.local/share/rtk` state on both.
