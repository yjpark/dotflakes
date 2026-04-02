---
# flakes-y87y
title: Add git worktree support to workspace commands
status: completed
type: feature
priority: normal
created_at: 2026-04-02T05:58:02Z
updated_at: 2026-04-02T05:58:58Z
---

Extend workspace-create, workspace-list, workspace-cd, workspace-delete, and completions to support git worktree in addition to jj workspaces. Runtime VCS detection (jj priority over git). Git worktrees create new branches by default.

## Summary of Changes

Added git worktree support to all workspace commands:
- workspace-create: detects jj vs git, uses git worktree add -b for git repos
- workspace-list: shows (jj)/(git) indicator per project, git worktrees show branch/hash/status
- workspace-cd: shows git branch/hash/status when navigating to git worktrees
- workspace-delete: uses git worktree remove for git repos
- completions: lists git worktrees alongside jj workspaces
- New helper __workspace_list_git_entry.fish for git worktree display formatting
