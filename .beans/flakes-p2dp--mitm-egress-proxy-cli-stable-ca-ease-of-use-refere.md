---
# flakes-p2dp
title: 'MITM egress-proxy CLI: stable CA + ease-of-use (reference)'
status: draft
type: task
tags:
    - reference
created_at: 2026-06-29T14:03:47Z
updated_at: 2026-06-29T14:03:47Z
---

Lessons from making a corporate egress-proxy CLI stable + easy to use. The tool MITMs all outbound HTTPS through a local proxy with its own CA. Patterns generalize to "any MITM-proxy-with-rotating-CA" setup.

**Note on scope:** this is a work-specific corporate tool that does **not** live in this flakes repo. Captured here as a reference bean for the lessons learned; the analogous in-repo pattern is the ingress CA bundle handling in `mixins/nixos/services/incus-ingress.nix`. Not directly implementable in this repo — treat as reference / draft.

## Lessons

- **CA must come from the real signing cert, not the management API.** The proxy's `/api/gateway/ca` endpoint can report a CA that does *not* match what it actually signs MITM certs with (regenerated-after-restart vs the persisted volume CA). Read the CA from the on-disk signing cert (`.../gateway/ca.pem`) instead. That one is stable (10-yr, survives restart/reboot; changes only on container *recreate*).
- **Persist the CA across recreate.** Back the proxy's data dir with a dedicated incus custom storage volume (bind-mounted), so CA + encryption key survive `delete+recreate`. Verified: CA hash unchanged across a full recreate.
- **The ingress CA bundle gets clobbered — re-append on every rebuild.** The dynamic ingress-config generator rebuilds the world-readable `ca-bundle.crt` as `cat system + caddy` on *every port change*, silently dropping the proxy CA that a separate service had appended. Net effect: TLS works right after boot, then breaks mid-session when a port change re-triggers ingress-sync. Fix: append the proxy CA inside the generator itself. (`git`/libcurl reads `SSL_CERT_FILE`/`NIX_SSL_CERT_FILE` -> the bundle, so once the CA is *in* the bundle, no per-command `http.sslCAInfo` flag is needed.)
- **git push over the proxy:** the proxy CA must be in the world-readable bundle; the root-only `ca.crt` (mode 000) isn't readable by the non-root user.
- **Ease-of-use wins:** rewrite `git@host:...` SSH URLs to HTTPS in container git config (SSH can't traverse the proxy); add a `:80` reverse-proxy to the dashboard for `*.incus` access; single personal write-PAT scoped by path whitelist (the proxy matches secrets by host/path only — no env/header/per-agent gating is possible, so path-scoping a single PAT is the workable model; most-specific pathPattern wins).
- **Caveat:** postgres isn't persisted, so a recreate still resets seeded secrets + agent token (re-run the reseed). Persisting postgres too would make recreates seamless.

## Todo

- [ ] (Reference only) Evaluate whether the "re-append CA inside the ingress generator" lesson applies to `incus-ingress.nix` here — currently `init-ingress-ca` resets the bundle on boot and `incus-pull-ca` re-appends manually
