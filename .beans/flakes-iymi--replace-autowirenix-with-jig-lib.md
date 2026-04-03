---
# flakes-iymi
title: Replace autowire.nix with jig lib
status: completed
type: task
priority: normal
created_at: 2026-04-03T15:11:37Z
updated_at: 2026-04-03T15:13:49Z
---

Migrate from standalone autowire.nix flake input to jig's lib.autowire. Add shim in flake.nix, rename default→wireImports, fix generic gatherFiles calls, update docs.

## Summary of Changes

- Replaced `autowire.url = "github:yjpark/autowire.nix"` with `jig.url = "github:edger-dev/jig"` in flake.nix
- Added shim: `inputs = inputs // { autowire = inputs.jig.lib.autowire; }` so all existing `flake.inputs.autowire.*` references keep working
- Renamed `autowire.default` → `autowire.wireImports` in 48 default.nix files
- Updated 3 files using generic `gatherFiles` → `gatherFiles_` (pre-applied variant)
- Updated CLAUDE.md and docs/src/architecture.md
- Verified with `nix flake show` — evaluates cleanly
