---
# flakes-oh4v
title: Add edit-in-place script
status: completed
type: task
priority: normal
created_at: 2026-03-20T13:06:29Z
updated_at: 2026-03-23T07:48:19Z
order: k
---

Create modules/home/scripts/edit-in-place.bash to back up and replace home-manager managed symlinks with writable copies for local testing

## Summary of Changes

Created modules/home/scripts/edit-in-place.bash — autowired automatically. Script backs up the symlink to .bak, removes the symlink, copies .bak back as a regular file, and sets 644 permissions.
