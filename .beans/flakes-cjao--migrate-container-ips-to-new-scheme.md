---
# flakes-cjao
title: Migrate container IPs to new scheme
status: completed
type: task
priority: normal
created_at: 2026-04-05T06:24:01Z
updated_at: 2026-04-05T12:28:43Z
parent: flakes-qbvb
---

Update static IPs: spacebot .102→.101, hermes .103→.102, ubuntu .101→.200. Update incus-ingress.nix, launch scripts, and dnsmasq config.

## Summary of Changes

- Updated : spacebot .102→.101, hermes .103→.102
- Updated @onecli static block to point to 10.100.0.2 (anticipating OneCLI containerization)
- Note: ubuntu container IP (.101→.200) is managed imperatively via `incus config device override ubuntu eth0 ipv4.address=10.100.0.200`
