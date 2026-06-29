---
# flakes-ja9k
title: Auto-restart firewalld when zone config changes
status: completed
type: bug
priority: normal
created_at: 2026-05-05T05:18:41Z
updated_at: 2026-06-29T14:12:20Z
---

NixOS services.firewalld module doesn't restart/reload the firewalld service when zone config changes, so switch-host applies new XML but the running daemon keeps old rules until manually restarted.

## Context

Discovered while debugging ICMP/ping access (commits 84638b0, 235381f). After running `mise run _switch-host` with new `services.firewalld.zones.lan` settings (added `protocols = ["icmp"]` and extra source range), the active runtime config from `firewall-cmd --zone=lan --list-all` still showed the old rules. Manual `sudo systemctl restart firewalld` was required.

## Investigation

- [x] Confirm root cause: nixpkgs `services.firewalld` sets **no** `restartTriggers`/`reloadTriggers`; zone/service XML lands in `/etc/firewalld/{zones,services}/*.xml` via `environment.etc`, disconnected from the unit
- [x] Decided **reload**: the unit already has `ExecReload = kill -HUP $MAINPID`; firewalld reloads permanent config on SIGHUP, non-disruptive
- [ ] (deferred) Check if upstream nixpkgs already has an open issue/PR — no web research done this shift

## Implementation

- [x] Added `systemd.services.firewalld.reloadTriggers` in `packs/nixos/common/settings/firewalld.nix` referencing every `firewalld/*` etc source (zones, services, policies, firewalld.conf)
- [x] Verified at eval/build: `reloadTriggers` resolves to the exact content-addressed zone/service XML store paths (incl. `zone-lan.xml` on a13); reviewer confirmed realized `X-Reload-Triggers` content. NOTE: live `_switch-host` + `firewall-cmd` test still pending on a physical host (cannot run from the yolo container)
- [ ] (follow-up) Consider upstreaming the `reloadTriggers` fix to nixpkgs

## Plan

Root cause **confirmed** by reading the nixpkgs `services.firewalld` module (`services/networking/firewalld/{default,zone,service}.nix`):

- Zone XML → `/etc/firewalld/zones/<name>.xml`, service XML → `/etc/firewalld/services/<name>.xml` (via `environment.etc`).
- The systemd unit sets `ExecReload = kill -HUP \$MAINPID` (firewalld reloads permanent config on SIGHUP) but has **no** `reloadTriggers`/`restartTriggers`. So when only the etc XML changes, the unit definition is unchanged and `switch-host` never reloads the daemon → stale runtime rules.

### Fix (reload, not restart — non-disruptive)

In `packs/nixos/common/settings/firewalld.nix`, set `systemd.services.firewalld.reloadTriggers` to the `.source` of every generated `firewalld/*` etc entry. Any zone/service XML change then flips the trigger and `switch-to-configuration` issues `systemctl reload firewalld` → SIGHUP → reload.

No upstream change attempted in this pass (note as possible follow-up).

## Summary of Changes

**File:** `packs/nixos/common/settings/firewalld.nix`

Added `systemd.services.firewalld.reloadTriggers`, computed from every `config.environment.etc` entry whose key starts with `firewalld/` (mapped to its `.source`). This covers `firewalld.conf`, `zones/*.xml`, `services/*.xml`, and `policies/*.xml`.

**Why it works:** the nixpkgs module writes firewalld permanent config to `/etc/firewalld/...` but never linked those files to the systemd unit, so `switch-host` left the daemon running stale rules. Wiring the etc sources into `reloadTriggers` makes `switch-to-configuration` issue `systemctl reload firewalld` whenever any firewalld config file content changes; the unit `ExecReload` sends SIGHUP and firewalld reloads its permanent config into runtime (non-disruptive).

**Decision:** chose reload (SIGHUP) over restart — matches the bean preference, no connection flush. `sysconfig/firewalld` (FIREWALLD_ARGS, needs a restart) is intentionally excluded; `extraArgs` is empty and rarely changes.

**Verification:** `nix eval`/`nix build` confirm `reloadTriggers` resolves to the exact content-addressed XML store paths; a review subagent independently built the `yolo` config and confirmed the realized `X-Reload-Triggers` content. Live `_switch-host` + `firewall-cmd --list-all` test is deferred to a physical host (not runnable from a container).

**Follow-ups:** check for / open an upstream nixpkgs issue or PR.
