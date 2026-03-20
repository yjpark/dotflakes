---
# flakes-nyvs
title: Update CLAUDE.md to reflect current state
status: completed
type: task
priority: normal
created_at: 2026-03-20T01:42:11Z
updated_at: 2026-03-20T05:24:41Z
order: zV
---

Fix outdated command names, module descriptions, overlays, flake inputs, and add Home Manager activation subsection

## Summary of Changes

- Fixed  → On branch dev
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   CLAUDE.md
	modified:   flake.lock

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.beans/flakes-nyvs--update-claudemd-to-reflect-current-state.md

no changes added to commit (use "git add" and/or "git commit -a")
- Fixed build-host description: "dry run" → "builds without switching"
- Simplified modules/ description (removed stale subdirectory list)
- Simplified mixins/ description (removed specific version numbers)
- Simplified configurations/ description (removed stale "plus version and platform mixins")
- Fixed overlays/default.nix description: autowires from `./` not `./packages/`
- Added Desktop/UI flake inputs group: claude-desktop, niri, xremap-flake, antigravity, jjui
- Added Home Manager Activation subsection covering yjpark/yj profiles, host/container mixin dirs, activate-home.nix logic, and home-configs.nix structure
