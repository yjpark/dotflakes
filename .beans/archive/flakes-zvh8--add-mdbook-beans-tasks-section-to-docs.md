---
# flakes-zvh8
title: Add mdbook-beans tasks section to docs
status: completed
type: task
priority: normal
created_at: 2026-03-28T13:53:47Z
updated_at: 2026-03-28T13:56:08Z
---

Integrate mdbook-beans preprocessor into the flakes documentation, mirroring the litmus project setup. Adds kanban and all-tasks pages.

## Summary of Changes

- Added `mdbook-beans` flake input to `flake.nix`
- Updated `docs/book.toml` with beans preprocessor config and sidebar CSS
- Created `docs/src/beans/tasks.md` (all tasks) and `docs/src/beans/kanban.md` (active tasks)
- Copied `docs/src/beans-sidebar.css` from litmus for bean styling
- Updated `docs/src/SUMMARY.md` with Kanban and All Tasks links
- Updated `modules/flake/docs.nix` to include mdbook-beans and .beans data in build
- Updated `mise.toml` docs tasks to use nix (ensuring mdbook-beans is available)
