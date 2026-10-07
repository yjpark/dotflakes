---
# flakes-x7wb
title: Remove k3s from g1 (offline during flakes-itu2)
status: todo
type: task
created_at: 2026-10-07T15:40:51Z
updated_at: 2026-10-07T15:40:51Z
---

g1 was offline when k3s was removed (flakes-itu2). Its config already has k3s and containerd disabled; it needs a switch plus the one-off runtime teardown that a13/p2 needed.

g1 imports `mixins/nixos/zfs`, so like a13/p2 it ran a **standalone containerd on the ZFS snapshotter** (dataset `rpool/state/containerd`, if it exists). `k3s-killall.sh` does not touch that containerd's pod shims, hence the manual teardown.

## Steps

1. Build on pc and diff against g1's running system (`nix store diff-closures`); stop if anything other than k3s/containerd/kube tooling removals appears.
2. Check `systemctl is-active mihomo` on g1 and that nix-daemon's proxy is `127.0.0.1:21102` — the k3s clash goes away with this.
3. `sudo $(dirname $(readlink -f $(command -v k3s)))/k3s-killall.sh` before switching (while k3s is still on PATH).
4. `nix copy --to ssh://g1.yjpark.zerotier <toplevel>`, then `nix-env -p /nix/var/nix/profiles/system --set` + `switch-to-configuration switch`.
5. Run the teardown script below, verify no failed units.

## Teardown script (as used on a13 and p2)

```bash
set -u
# 1. Kill every pod process via the cgroup, then the shims.
[ -e /sys/fs/cgroup/kubepods/cgroup.kill ] && echo 1 | sudo tee /sys/fs/cgroup/kubepods/cgroup.kill >/dev/null
sudo pkill -f 'containerd-shim-runc-v2 -namespace k8s.io'
for i in $(seq 1 20); do pgrep -f 'containerd-shim-runc-v2 -namespace k8s.io' >/dev/null || break; sleep 1; done
echo "shims left: $(pgrep -cf 'containerd-shim-runc-v2 -namespace k8s.io')"
# 2. Unmount everything containerd/kubelet left, deepest first.
mount | awk '{print $3}' | grep -E '^/run/containerd|^/var/lib/containerd|^/var/lib/kubelet|^/run/k3s' | sort -r | while read -r m; do sudo umount -l "$m" 2>/dev/null || true; done
echo "mounts left: $(mount | grep -cE '/run/containerd|/var/lib/containerd|/var/lib/kubelet|/run/k3s')"
# 3. Remove the empty pod cgroup tree, bottom-up.
[ -d /sys/fs/cgroup/kubepods ] && sudo find /sys/fs/cgroup/kubepods -depth -type d -exec rmdir {} \; 2>/dev/null
echo "kubepods cgroup: $([ -d /sys/fs/cgroup/kubepods ] && echo present || echo gone)"
# 4. Destroy containerd's ZFS snapshotter dataset.
if zfs list -H rpool/state/containerd >/dev/null 2>&1; then sudo zfs destroy -r rpool/state/containerd && echo "zfs rpool/state/containerd destroyed"; fi
# 5. State directories.
sudo rm -rf /var/lib/containerd /run/containerd /var/lib/rancher /etc/rancher /var/lib/kubelet /run/k3s /run/flannel
rm -rf ~/.kube
for d in /var/lib/containerd /run/containerd /var/lib/rancher /etc/rancher /var/lib/kubelet ~/.kube; do [ -e "$d" ] && echo "STILL PRESENT: $d"; done
echo "failed units: $(systemctl --failed --no-legend | wc -l)  mihomo: $(systemctl is-active mihomo)"
zfs list -H -o name -d1 rpool/state
```

## Todo

- [ ] Diff, deploy and tear down on g1
