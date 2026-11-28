---
# flakes-ry0c
title: Drive implementation from intake notes
status: completed
type: feature
created_at: 2026-11-28T11:30:41Z
updated_at: 2026-11-28T13:51:37Z
---

Console inbox lists remote notes. Start implementation creates and links a context, sets a permitted wake node, and enqueues small serial implementation steps. Ordinary ready work auto-starts only for contexts with an explicit wake node; other contexts keep existing behavior and no context gets a second concurrent worker. Done when tests, full workspace, Nix/Home Manager builds, and a live note-to-worker smoke test pass. Worktrees and PRs are out of scope.

Completed with kudo pinned at fe899ae and the edger receiver targeting the dedicated `/home/yjpark/intake/kudo` checkout. Live note `console-intake-smoke-20261128-01` started one `yolo` worker for context `2dda0b25828bf6ed2e4b63feeb0f46c8623124c2daab73d7fb48f1345d64eaa1`; the worker submitted evidence, and repeated delivery and Start implementation were idempotent.
