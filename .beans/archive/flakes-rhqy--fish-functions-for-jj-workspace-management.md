---
# flakes-rhqy
title: Fish functions for jj workspace management
status: completed
type: feature
priority: normal
created_at: 2026-04-01T05:40:08Z
updated_at: 2026-04-04T17:51:46Z
---

Convention-based jj workspace management via fish shell functions. All workspaces at ~/workspaces/<project>/<feature> with a registry file at ~/.config/workspaces.conf for mapping project names to main repo paths.

## Functions

| Abbr | Full name | Behavior |
|------|-----------|----------|
| wl | workspace-list | List all workspaces across all projects with bookmark + dirty/conflict status |
| w | workspace-cd | cd to a workspace + show brief status. Tab-completes <project>/<feature> |
| wc | workspace-create | From inside a repo, create ~/workspaces/<project>/<feature> via jj workspace add |
| workspace-delete | (no abbr) | Forget + remove a workspace |

## Design Details

### Convention
- All workspaces at ~/workspaces/<project>/<feature>
- <project> = basename of the main repo root
- Default workspace = the main repo itself

### Registry (~/.config/workspaces.conf)
- Maps project name to main repo path (e.g. llm-triage=/home/yj/code/llm-triage)
- Auto-populated by wc on first use
- Needed to discover default workspace / run jj commands from the right root

### workspace-list (wl)
- Iterates all registered projects
- For each: runs jj workspace list from main repo, then for each workspace shows:
  - Workspace name (default or feature name)
  - Path (main repo or ~/workspaces/<project>/<feature>)
  - Bookmark name (or 'no bookmark')
  - Change-id (short)
  - Status: clean / dirty / conflicts
- Grouped by project

### workspace-cd (w)
- w <project>/<feature> → cd to workspace path + print one-line status (bookmark, change-id, dirty/conflicts)
- w <project>/default → cd to main repo root
- Tab completion for all <project>/<feature> combos
- w with no args → do nothing

### workspace-create (wc)
- Must be run from inside a jj repo
- wc <feature> → jj workspace add ~/workspaces/<project>/<feature>
- Auto-registers project in ~/.config/workspaces.conf if not present
- cd to the new workspace after creation

### workspace-delete
- workspace-delete <project>/<feature> → jj workspace forget <feature> (from main repo) + rm -rf the directory
- No abbreviation (destructive operation)
- Tab completion same as w

## Tasks

- [x] Create workspace-list.fish function
- [x] Create workspace-cd.fish function with completions
- [x] Create workspace-create.fish function
- [x] Create workspace-delete.fish function
- [x] Add abbrs (wl, w, wc) to abbrs.nix
- [x] Wire functions into fish module via nix (autowired automatically)
