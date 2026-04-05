---
# flakes-dght
title: Drop nixos-unified, use raw flake-parts
status: in-progress
type: task
priority: high
created_at: 2026-04-05T06:23:52Z
updated_at: 2026-04-05T06:24:07Z
parent: flakes-qbvb
---

Replace nixos-unified.lib.mkFlake with flake-parts.lib.mkFlake. Separate host and container config namespaces. Rewrite home-configs.nix and activate-home.nix to own the logic directly. Keep autowire (from jig) for module discovery.
