---
# flakes-wsls
title: 'nix-daemon: route cache.nixos.org through proxy'
status: in-progress
type: bug
priority: normal
created_at: 2026-10-07T14:53:27Z
updated_at: 2026-10-11T15:10:02Z
---

On edger, direct cache.nixos.org NAR fetch ~22KB/s vs ~338KB/s via clash; tuna mirror returns 403 so everything falls through to direct cache.nixos.org, making switch-host very slow. Remove cache.nixos.org from no_proxy in mixins/nixos/cn/proxy-env.nix.

## Todo
- [x] Remove cache.nixos.org from noProxy
- [x] Drop tuna substituter (mixins/nixos/cn/mirrors.nix) and its no_proxy entry
- [ ] Switch host and verify faster substitution

Note: a stale imperative /run/systemd/system/nix-daemon.service.d/override.conf (10.0.4.13:1102) still exists on edger; remove it after switching.
