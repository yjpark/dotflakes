---
# flakes-jvmx
title: Set up firewalld as NixOS service and migrate existing firewall rules
status: in-progress
type: task
priority: normal
created_at: 2026-03-16T13:50:47Z
updated_at: 2026-03-16T13:52:55Z
---

## Objective

Replace NixOS's built-in `networking.firewall` with firewalld across all hosts, enabling zone-based firewall management that integrates natively with incus.

## Context

The repo currently uses NixOS's `networking.firewall` — a simple declarative wrapper around iptables/nftables. This works for basic port allowlisting but doesn't support zone-based policies. With incus now in the stack (`mixins/nixos/services/incus.nix`), zone-based rules are a better fit:

- **Incus has built-in firewalld support** — it can automatically manage zones for bridge interfaces (`incusbr0`), so containers/VMs get proper network isolation without manual rules.
- **Already on nftables** — `networking.nftables.enable = true` is set in the incus mixin. firewalld uses nftables as its default backend, so there's no backend conflict.
- **Current LAN rules use raw iptables** — the `extraCommands` in `mixins/nixos/lan/*/firewall.nix` inject iptables rules directly, which won't work under firewalld's managed ruleset.
- **Zone-based model is cleaner** — instead of scattering port ranges across files, interfaces get assigned to zones with appropriate policies.

## Requirements

### 1. Enable firewalld as a NixOS service

- Set `services.firewalld.enable = true` in an appropriate NixOS module
- This automatically disables `networking.firewall` — both cannot be active simultaneously

### 2. Migrate all existing `networking.firewall` usages

The following files need migration:

| File | Current rules | Migration approach |
|------|--------------|-------------------|
| `mixins/nixos/lan/my/firewall.nix` | Open ports 1000-65535 for `10.0.0.0/8` (iptables) | Create a zone (e.g., "lan") with these rules, assign LAN interface |
| `mixins/nixos/lan/cn/firewall.nix` | Same as above | Same zone approach |
| `mixins/nixos/dev/ports.nix` | TCP ranges 3000-3999, 8000-8999, 29000-29999 | Add port ranges to appropriate zone |
| `modules/nixos/services/airplay.nix` | TCP 7000,7001,7100 + UDP 6000,6001,7011 | firewalld service definition or rich rules |
| `modules/nixos/services/clash-verge.nix` | TCP ports for clash | firewalld service or zone rules |
| `modules/nixos/services/zerotierone.nix` | UDP port for zerotier | firewalld service or zone rules |
| `mixins/nixos/ext4/k3s.ext4.nix` | k3s TCP ports + ranges | firewalld zone for k3s |
| `mixins/nixos/zfs/k3s.zfs.nix` | k3s TCP ports + ranges | firewalld zone for k3s |
| `configurations/nixos/alienware-13/ports.nix` | TCP 2342 (photoprism) | firewalld service or zone rule |

### 3. Configure incus integration

- Ensure `incusbr0` bridge interface is assigned to an appropriate firewalld zone
- Verify incus can manage its own firewall rules through firewalld without manual intervention

### 4. Design the zone layout

Decide on zones — at minimum:
- **public** (default) — external-facing interface, restrictive
- **trusted** or custom **lan** zone — for `10.0.0.0/8` traffic with broader access
- **incus** zone — for `incusbr0`, managed by incus

## Acceptance Criteria

- [ ] `services.firewalld` is enabled and `networking.firewall` is no longer used
- [ ] All previously open ports/ranges remain accessible in the correct contexts
- [ ] LAN-scoped rules (`10.0.0.0/8` broad access) work via firewalld zones instead of raw iptables
- [ ] Incus containers/VMs have working network access through `incusbr0`
- [ ] No regressions — services (airplay, clash-verge, zerotier, k3s, photoprism) remain reachable
- [ ] `nix fmt` passes on all changed files

## Dependencies

- Depends on incus being configured (already done in `mixins/nixos/services/incus.nix`)
- Hosts not using incus should still work with firewalld (zone config just won't include incus zone)
