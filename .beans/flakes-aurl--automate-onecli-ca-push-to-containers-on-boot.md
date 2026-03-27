---
# flakes-aurl
title: Automate OneCLI CA push to containers on boot
status: completed
type: task
priority: normal
created_at: 2026-03-27T14:46:14Z
updated_at: 2026-03-27T14:57:18Z
---

OneCLI CA cert gets wiped from container CA bundles on reboot/rebuild. Extend onecli-seed-secrets to also push the CA, and add wantedBy=multi-user.target + after=incus.service so it runs on every boot.

## Design

**Problem:** `init-ingress-ca` on yolo copies system CAs to `/var/lib/ingress/ca-bundle.crt` on boot, wiping the OneCLI CA that was previously appended by `onecli-push-ca`. This breaks all HTTPS through the OneCLI MITM proxy (nix downloads, curl, git, etc.) until someone manually runs `onecli-push-ca yolo`.

**Solution:** Extend `onecli-seed-secrets` on edger (host) to:
1. Fetch OneCLI CA from `http://10.100.0.1:10254/api/gateway/ca`
2. Push to each running agent container via `incus file push`
3. Append to CA bundles inside the container (handling Nix store symlinks + idempotency)

Also update the systemd service:
- Add `wantedBy = ["multi-user.target"]` — runs on every boot
- Add `after = [..., "incus.service"]` — ensures incus is up

**Files to modify:**
- `mixins/nixos/services/onecli.nix` — extend seeder script + service config

**Known gap:** Container-side `nixos-rebuild switch` resets CA bundles. User must re-run `sudo systemctl start onecli-seed-secrets` on host. Acceptable since container rebuilds are manual.

## Tasks

- [x] Add CA push logic to seeder script in onecli.nix
- [x] Rename `onecli-seed-secrets` service to `onecli-init-ca-and-secrets` (systemd service + script name)
- [x] Add `wantedBy` and `after` incus.service to systemd service
- [x] Add `onecli-init-ca-and-secrets` shell script on host (starts the systemd service via sudo) for easy manual use
- [x] Update `onecli-check-proxy.bash` error messages to suggest running `onecli-init-ca-and-secrets` on the host
- [x] Add CA bundle verification to check script: detect broken TLS (e.g. curl to github.com fails but `--noproxy` works) and surface a clear diagnosis
- [x] Update `_switch-host` in mise.toml to reference new service name
- [x] Verify build with `mise run build-host`


## Summary of Changes

1. **`mixins/nixos/services/onecli.nix`** — Renamed service `onecli-seed-secrets` → `onecli-init-ca-and-secrets`. Added CA push logic (fetch from API, push to containers, append to CA bundles with symlink handling + idempotency). Added `wantedBy = ["multi-user.target"]` and `after = ["incus.service"]` so it runs on every boot.
2. **`mise.toml`** — Updated `_switch-host` and `restart-onecli` tasks to reference new service name.
3. **`mixins/home/host/linux/scripts/incus/onecli-init-ca-and-secrets.bash`** — New host script for easy manual triggering.
4. **`mixins/home/container/scripts/onecli-check-proxy.bash`** — Updated error messages to point to `onecli-init-ca-and-secrets`. Added TLS verification check that detects "proxy works but TLS fails" scenario and surfaces clear fix instructions.
