---
# flakes-7g5s
title: Remove spacebot and hermes containers
status: completed
type: task
priority: normal
created_at: 2026-10-15T13:49:31Z
updated_at: 2026-10-15T14:02:56Z
---

Remove spacebot and hermes entirely: container configs, home mixins, launch/restart scripts, abbrs, flake inputs (spacebot, hermes-agent, hermes-webui, opencode-claude-code-plugin), ingress entries, onecli script defaults, incus instances/images. Host data dirs ~/bots/{hermes,agents} are kept.

- [x] Remove from repo
- [x] Update flake.lock and build check
- [x] Delete incus instance/images and activate host

## Summary of Changes

Removed container configs, home mixins, incus launch/restart scripts, abbrs, the spacebot/hermes-agent/hermes-webui/opencode-claude-code-plugin inputs (lock pruned, nothing else updated), ingress entries (10.100.0.101/.102) and the onecli script defaults (now just yolo). Deleted the hermes incus instance + snapshot and the spacebot/hermes images (the spacebot instance was already gone). Kept host data in ~/bots/hermes and ~/bots/agents. Also skip .gitkeep in flake/home-configs.nix (it generated a bogus yj@.gitkeep config once the containers dir became empty). Switched edger + home; yolo switched natively via `mise run _switch-host`.
