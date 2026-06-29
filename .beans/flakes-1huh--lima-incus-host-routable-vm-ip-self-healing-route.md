---
# flakes-1huh
title: lima->incus host-routable VM IP + self-healing route (macOS)
status: draft
type: task
tags:
    - reference
    - networking
created_at: 2026-06-29T14:03:48Z
updated_at: 2026-06-29T14:03:48Z
parent: flakes-qbvb
---

Reaching incus containers (e.g. `10.100.0.0/24`) directly from macOS, surviving reboots and VM IP changes.

**Note on scope:** the moving parts here are macOS-side — a lima VM template and launchd agents on the Mac host. This flakes repo manages NixOS/home-manager, **not** the macOS host or the lima template, so this is largely **external**. Captured as a reference/draft bean; the in-repo touchpoint is `boot.autostart` and container networking inside incus.

## Design

- **vzNAT network** in the lima template gives the VM a host-routable IP (Mac `192.168.64.1`, VM `192.168.64.5`); the container reaches the Mac via VM NAT. This is the substrate the MCP OAuth bridge rides on.
- **Self-healing route:** a launchd agent runs an idempotent `ensure-route` — it only touches the routing table when the route is missing or stale (no-op + no sudo when it already points at the VM's current IP). A one-time `route-allow-sudo` drops a narrow sudoers line so the agent can maintain the route unattended.
- **VM auto-start** via a launchd agent so containers survive Mac reboots (`boot.autostart` inside, agent restores the route once the VM is up).

## Todo

- [ ] (External) lima template with vzNAT network
- [ ] (External) launchd `ensure-route` agent + narrow `route-allow-sudo` sudoers line
- [ ] (External) launchd VM auto-start agent
- [ ] (In-repo, if applicable) confirm `boot.autostart` is set on incus containers that should survive reboots
