---
# flakes-jspq
title: Reconsider k3s on pc once only minio remains
status: draft
type: task
priority: normal
created_at: 2026-10-05T14:21:21Z
updated_at: 2026-10-05T14:21:34Z
parent: flakes-qbvb
blocked_by:
    - flakes-k0sx
---

Once [[flakes-k0sx]] moves clash to a host `services.mihomo` service and drops
`yacd`, k3s on `pc` hosts only **minio** (plus traefik, which exists purely for
minio's two ingresses). Worth deciding whether that still justifies a
single-node Kubernetes cluster.

## State after the clash migration

- `pod/minio-0` (StatefulSet), `svc/minio` (ClusterIP 9000/9001)
- `ingress/minio-api` → `minio.pc.yjpark.org`
- `ingress/minio-console` → `minio-ui.pc.yjpark.org`
- traefik, kept only for those two ingresses
- `mixins/nixos/ext4/k3s.ext4.nix` opens 6443, 80, 443 and the whole
  **30000-32767** NodePort range to the firewalld `public` zone — with no
  NodePort consumers left, that range can be closed regardless of what is
  decided here.

## Options

1. **Keep k3s.** Zero work. Retains a place to drop future workloads, at the
   cost of a control plane and traefik for one service.
2. **minio → incus container**, drop k3s and traefik from `pc`, and give `pc`
   `mixins/nixos/services/incus-ingress.nix` so it uses the same host-Caddy
   pattern `edger` already uses. Unifies the two hosts on one ingress story and
   fits the parent epic. Touches minio's data volumes and both DNS names.
3. **minio → host service** (`services.minio`). Simplest runtime, but breaks the
   container-first direction of the epic and still needs an ingress for the two
   hostnames.

## Note

There is an architectural inconsistency worth resolving either way: `edger` uses
host Caddy + incus containers (`mixins/nixos/services/incus-ingress.nix`), while
`pc` uses k3s + traefik. Only `pc` runs k3s.

## Tasks

- [ ] Decide between the three options above
- [ ] Narrow or remove the 30000-32767 public NodePort range in `mixins/nixos/ext4/k3s.ext4.nix` (safe to do as soon as no NodePort consumers remain)
