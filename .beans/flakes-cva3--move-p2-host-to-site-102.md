---
# flakes-cva3
title: Move p2 host to site 102
status: completed
type: task
priority: normal
created_at: 2026-10-06T15:07:13Z
updated_at: 2026-10-06T15:07:25Z
---

p2 physically moved to site 102 (10.0.1.0/24). Switch its lan mixin import and move its hosts entries (.5 p2, .12 p2_wifi) from lan/401 to lan/102.

## Summary of Changes

- nixos/hosts/p2/imports.nix: import lan/102 instead of lan/401
- Moved p2 (.5) and p2_wifi (.12) host entries from lan/401 to lan/102, keeping their last octets
- Verified: p2 site.subnet evaluates to 10.0.1.0/24; pc's /etc/hosts now lists p2 at 10.0.1.5
