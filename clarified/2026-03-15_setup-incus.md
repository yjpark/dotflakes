---
provider:
type: task
title: "Set up Incus across machines"
date: 2026-03-15
status: clarified
---

## Goal

Set up Incus (container/VM manager) across all machines managed by this flakes repo. The daemon runs on select NixOS hosts via a mixin; the client is available everywhere via Home Manager.

## Approach

### 1. NixOS daemon mixin — `mixins/nixos/services/incus.nix`

- Enable `virtualisation.incus` service
- Enable KVM support for VM workloads
- Configure a directory-based storage pool (simple, no ZFS/Btrfs dependency)
- Default NAT networking for containers/VMs
- Add user to the `incus-admin` group
- Hosts opt in by including this mixin in their configuration

### 2. Home Manager client module — `modules/home/packages/incus.nix`

- Install the `incus` client package
- Enable fish shell completions
- Shared across all platforms (NixOS, non-NixOS Linux, macOS)

### 3. Sample remote config — `mixins/home/settings/incus/edger.nix`

- Configure a remote named `edger` pointing to `edger.yjpark.org`
- Hosts opt in by including this mixin

## Decisions made

- **No multi-host clustering** — keep it simple, single-host only
- **Both containers and VMs supported** — KVM enabled on NixOS hosts
- **Directory-based storage pool** — avoids filesystem dependencies
- **No abbreviations for now** — Incus will mostly be used in automated environments
- **macOS VM layer (colima) is a separate future task**

## Out of scope

- Colima setup for macOS (future task)
- Multi-host clustering
- ZFS/Btrfs storage backends
- Incus UI
