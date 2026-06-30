---
# flakes-ihxf
title: Declarative incus fleet management
status: draft
type: feature
priority: low
created_at: 2026-04-05T06:24:02Z
updated_at: 2026-06-30T00:20:47Z
parent: flakes-qbvb
---

NixOS module to declare containers (image, IP, devices, ACLs) and have them rebuild/restart on _switch-host. Long-term goal.

## Design notes (night-shift planning pass, 2026-06-30)

Not implemented this shift: building a declarative incus orchestration layer would mutate the live fleet (create/configure/restart containers) — unverifiable in CI and risky to run unattended, and it hinges on design decisions that are architect calls. Captured the design surface so it's actionable later. Set to draft (needs design refinement before implementation), per the repo's planning≠implementation rule.

### Current state (what this would supersede / build on)
- **Imperative launch/restart scripts:** `packs/home/host/linux/scripts/incus/incus-launch-*.bash`, `incus-restart-*.bash`, `incus-setup-storage-ext4.bash` — per-container shell, run by hand.
- **Host incus enablement:** `packs/home/host/linux/incus.nix`, `packs/nixos/host/incus.nix`, `mixins/home/settings/incus/`.
- **Static fleet list already exists** in `mixins/nixos/services/incus-ingress.nix` as `ingressContainers = [ { name; ip; } ... ]` (onecli .2, searxng .3, yolo .100, spacebot .101, hermes .102). A declarative fleet module should become the **single source of truth** feeding both container creation *and* this ingress list (DRY).
- Containers are a mix: NixOS containers (`nixos/containers/*`) and Ubuntu (`packs/home/container/scripts/ubuntu-setup-*.bash`).

### Key design decisions (need a call before implementation)
1. **Option schema:** e.g. `services.incus.fleet.<name> = { image; ipv4; devices; profiles; acls; storageVolumes; autostart; ... }`.
2. **Reconciliation model:** activation script / systemd oneshot on `_switch-host` that diffs declared vs `incus list --format json` and creates/configures/restarts. Must be **idempotent and non-destructive** (never delete/recreate a container with data; the egress-proxy work showed CA/postgres data lives on custom storage volumes that must persist across recreate).
3. **Image source:** build NixOS container images from this flake (reproducible) vs. pull Ubuntu images vs. both. Affects how "image" is declared.
4. **Scope of management:** devices (proxy/disk/gpu), `ipv4.address` overrides (currently set by hand via `incus config device override`), network ACLs, profiles, storage volumes.
5. **Restart policy:** what changes trigger a restart vs. a live `incus config` apply; avoid disrupting running services unnecessarily.
6. **Migration:** supersede the imperative `incus-launch-*`/`incus-restart-*` scripts, or coexist during transition.

### Proposed phased decomposition (create as child beans once decisions above are made)
1. `fleet` option schema only (pure types, no side effects) + derive `ingressContainers` from it.
2. Read-only reconciler: report drift between declared fleet and `incus list` (no mutation) — safe to land + verify first.
3. Create/ensure containers from declarations (idempotent, non-destructive; storage volumes persist).
4. Device / ACL / profile / IP-override management.
5. Wire restart-on-change into `_switch-host`; migrate the imperative scripts.
