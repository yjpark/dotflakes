---
# flakes-ja9k
title: Auto-restart firewalld when zone config changes
status: todo
type: bug
priority: normal
created_at: 2026-05-05T05:18:41Z
updated_at: 2026-05-05T05:18:52Z
---

NixOS services.firewalld module doesn't restart/reload the firewalld service when zone config changes, so switch-host applies new XML but the running daemon keeps old rules until manually restarted.

## Context

Discovered while debugging ICMP/ping access (commits 84638b0, 235381f). After running `mise run _switch-host` with new `services.firewalld.zones.lan` settings (added `protocols = ["icmp"]` and extra source range), the active runtime config from `firewall-cmd --zone=lan --list-all` still showed the old rules. Manual `sudo systemctl restart firewalld` was required.

## Investigation

- [ ] Confirm root cause: check whether nixpkgs `services.firewalld` module sets `restartTriggers` / `reloadTriggers` on the systemd unit when zone XML or settings change
- [ ] Decide between restart vs reload (`firewall-cmd --reload` is non-disruptive and is likely what we want)
- [ ] Check if upstream nixpkgs already has an open issue/PR

## Implementation

- [ ] Add a fix in `packs/nixos/common/settings/firewalld.nix` — likely a `systemd.services.firewalld.reloadTriggers` referencing the generated zone config files, or a small activation script that runs `firewall-cmd --reload` when config changes
- [ ] Test by editing a zone (e.g. add a port), running `_switch-host`, and verifying `firewall-cmd --zone=… --list-all` reflects the change without manual intervention
- [ ] If a clean fix exists, consider upstreaming to nixpkgs
