---
# flakes-z12t
title: Deduplicate kudo MCP agent sessions
status: completed
type: bug
priority: normal
created_at: 2026-11-26T16:29:08Z
updated_at: 2026-11-26T16:36:03Z
---

Multiple MCP client processes for one agent appeared as independent bare sessions with disconnected mailboxes. Pin hub and kudo revisions with shared logical registrations, and derive KUDO_SESSION_ID from parent PID plus parent start time and workspace in the kudo-mcp launcher. Set explicit Kimi/Claude harness metadata. Done when yolo, edger, and pc Home Manager builds pass, real duplicate clients appear once and share delivery, and the change is pushed.
