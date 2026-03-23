---
# flakes-ojyn
title: Refactor ai.nix into ai/ directory
status: completed
type: task
priority: normal
created_at: 2026-03-23T02:20:53Z
updated_at: 2026-03-23T02:21:40Z
---

Convert mixins/home/host/common/ai.nix into a folder (ai/), moving scripts/installs/ under ai/installs/ and extracting inline scripts into bash files.

## Summary of Changes

- Converted `mixins/home/host/common/ai.nix` → `ai/` directory
- `ai/default.nix`: autowire pattern for extensibility
- `ai/ai.nix`: package declarations (bun, nodejs_25)
- `ai/installs/default.nix`: gatherScriptPackages_bash
- Moved `scripts/installs/install-claude-mcp-context7.bash` and `install-claude-mcp-verena.bash` → `ai/installs/`
- Extracted inline clone-beans and install-ccline scripts into `ai/installs/`
- Removed `scripts/installs/` directory (now empty)
