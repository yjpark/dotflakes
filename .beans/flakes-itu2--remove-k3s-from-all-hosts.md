---
# flakes-itu2
title: Remove k3s from all hosts
status: completed
type: task
priority: normal
created_at: 2026-10-07T15:25:12Z
updated_at: 2026-10-07T15:40:51Z
---

k3s is no longer needed anywhere. Remove it from every host's config, tear down its runtime state, and drop Kubernetes tooling from the home config.

## State found (2026-10-07)

| Host | k3s | Workloads |
|---|---|---|
| pc | running | cert-manager, stale clash + yacd (replaced by host mihomo, flakes-k0sx), minio (empty: only `.minio.sys`, 120K) |
| edger | running | cert-manager, stale clash + yacd |
| a13 | running | cert-manager, clash + yacd, minio in ImagePullBackOff (1K volume) |
| p2 | inactive | — |
| g1 | offline | unknown — picks up the change on its next switch |

No repo references to the clash NodePorts (3110x) or minio remain. No data to preserve.

## Decisions

- Wipe k3s state on each deployed host (`k3s-killall.sh`, then `/var/lib/rancher`, `/etc/rancher`, `/var/lib/kubelet`, CNI leftovers).
- Remove generic kubectl bits from home config too (`k` abbr, `KUBECONFIG`).
- Deploy now to pc, edger, a13, p2 — diff each closure first, stop if unrelated changes come along.
- Supersedes flakes-jspq (minio has no data, nothing to migrate).

## Todo

- [x] Delete `mixins/nixos/ext4` (k3s only) and its imports on pc/edger
- [x] Delete `mixins/nixos/zfs/k3s.zfs.nix` (k3s + containerd for it); keep zfs scripts
- [x] Drop k3s/containerd branches from `mixins/nixos/cn/proxy-env.nix`
- [x] Remove `copy-k3s-yaml.bash`, `k`/`kn` abbrs (fish + nushell), `KUBECONFIG`, `k8s.nix` (kubectl, kubectx, kubeshark, kubespy, kompose, kubevela), `k9s.nix`
- [x] Update monitoring comment that mentions k3s pods (also incus-ingress traefik-disable flag, egress-proxy comment)
- [x] Evaluate all five hosts (k3s + containerd disabled on all; home configs yjpark/yj evaluate)
- [x] Deploy + clean up pc (diff removals only; k3s-killall.sh, switch, wiped /var/lib/rancher 2.6G, /etc/rancher, /var/lib/kubelet, /run/k3s, /run/flannel, ~/.kube)
- [x] Deploy + clean up edger (built on pc, diff removals only; wiped /var/lib/rancher 5.5G)
- [x] Deploy + clean up a13
- [x] Deploy + clean up p2
- [x] Close out flakes-jspq and k3s leftovers in flakes-k0sx

## Summary of Changes

- Config: removed `mixins/nixos/ext4` (k3s only) and `mixins/nixos/zfs/k3s.zfs.nix` (k3s + standalone containerd on the ZFS snapshotter), k3s/containerd branches of `cn/proxy-env.nix`, the incus-ingress traefik flag, and Kubernetes tooling from home (k8s.nix, k9s.nix, copy-k3s-yaml, k/kn abbrs, KUBECONFIG). k3s and containerd now disabled on all five hosts.
- Deployed to pc, edger, a13, p2 (each built on pc, closure diff removals only, copied with nix copy). Teardown: k3s-killall.sh, then state dirs and ~/.kube removed.
- a13/p2 ran a standalone containerd that k3s-killall.sh does not touch: pod shims kept running after the switch. Killed via the kubepods cgroup, unmounted leftovers, `zfs destroy -r rpool/state/containerd`. Teardown script recorded in flakes-x7wb.
- Before removal on a13/p2, confirmed host mihomo active and nix-daemon proxied via 127.0.0.1:21102, so dropping the k3s clash broke nothing.
- g1 was offline: follow-up flakes-x7wb.
