---
# flakes-p8hf
title: Unify incus container image build tasks
status: completed
type: task
priority: normal
created_at: 2026-04-05T13:32:17Z
updated_at: 2026-04-05T13:32:50Z
---

Replace per-container build-image/build-metadata/build-and-import tasks with a single parameterized task that builds image+metadata and imports directly without staging in images/

## Summary of Changes

Replaced 9 per-container tasks (build-yolo-image, build-yolo-metadata, build-and-import-yolo, and equivalents for spacebot/hermes) with a single `mise run build-container <name>` task.

- Uses `usage` field with KDL `choices` for shell auto-complete (covers all 5 containers)
- Builds metadata + image sequentially, resolves nix store paths directly from `result` symlink
- Pipes both tarballs straight to `incus image import` — no `images/` staging directory needed
- Removed `images/` directory entirely
