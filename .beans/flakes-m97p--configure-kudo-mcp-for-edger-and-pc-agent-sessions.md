---
# flakes-m97p
title: Configure kudo MCP for edger and pc agent sessions
status: completed
type: feature
priority: normal
created_at: 2026-11-26T15:09:38Z
updated_at: 2026-11-26T15:25:24Z
---

Register the kudo stdio MCP globally for Kimi Code and Claude Code wherever the kudo-node home module is enabled (edger, pc, and their yolo containers). Launch through a runtime wrapper that loads the existing container hub.env or host sops kudo-hub-user.env without placing credentials in MCP JSON or the Nix store. Done when the affected home configurations build, new sessions advertise session_list/session_send/session_messages, and a real installed-shim MCP call authenticates successfully.
