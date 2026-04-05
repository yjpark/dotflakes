---
# flakes-x821
title: Container-to-host network isolation
status: completed
type: task
priority: normal
created_at: 2026-04-05T06:23:56Z
updated_at: 2026-04-05T12:33:11Z
parent: flakes-qbvb
---

Add nftables INPUT rules on incusbr0 to block container→host traffic except DHCP (67/68) and DNS (53/5354). Container↔container traffic via FORWARD chain stays unrestricted.

## Summary of Changes

- Updated `packs/nixos/host/incus.nix`: removed `target = "ACCEPT"` from incus firewalld zone
- Added explicit services: "dhcp" (UDP 67) and "dns" (TCP/UDP 53) for container→host DHCP/DNS
- Added ports 5354 TCP/UDP for custom dnsmasq DNS
- Container↔container traffic via FORWARD chain is unaffected (bridge forwarding)
