---
# flakes-pr3i
title: Setup OpenCode and Claude for spacebot container
status: completed
type: task
priority: normal
created_at: 2026-04-04T18:14:48Z
updated_at: 2026-04-05T12:42:19Z
---

Configure OpenCode with the claude-code-plugin (github:unixfox/opencode-claude-code-plugin) in the spacebot incus container, enabling Claude as a coding assistant within spacebot's environment.

## Summary of Changes

- Added `opencode-claude-code-plugin` flake input (github:unixfox/opencode-claude-code-plugin, flake=false)
- Updated `mixins/home/containers/spacebot.nix`:
  - Added `llm-agents.opencode` and `llm-agents.claude-code` to packages
  - Added `xdg.configFile."opencode/plugins/claude-code"` pointing to plugin source
- Plugin placed at `~/.config/opencode/plugins/claude-code` for OpenCode to load
- Also fixed minor bug in spacebot-restart (was calling spacebot-restart instead of spacebot-status)
