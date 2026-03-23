---
# flakes-2aqm
title: Deploy OneCLI as credential proxy for yolo container
status: completed
type: feature
priority: normal
created_at: 2026-03-23T03:40:59Z
updated_at: 2026-03-23T07:39:45Z
---

Set up OneCLI (MITM proxy) on edger host to inject API keys for agents running in the yolo Incus LXC container. Agents get placeholder keys; OneCLI injects real credentials at the network layer.

## Tasks

- [x] Create mixins/nixos/services/onecli.nix (OCI containers + seeder service)
- [ ] Create mixins/nixos/services/secrets/onecli-secrets.txt (sops-encrypted)
- [x] Modify configurations/nixos/edger/imports.nix (enable onecli)
- [x] Modify mixins/home/ai/tools/claude-mcp-add-context7.bash (use placeholder key)
- [x] Modify mixins/home/host/linux/scripts/incus/incus-launch-yolo.bash (push CA cert)

## context7 Rule Fix

- [x] Update seeder to use per-secret config (hostPattern + headerName + valuePrefix)
- [x] Add CONTEXT7_API_KEY entry targeting context7.com with Authorization: Bearer injection


## Proxy Auth & CA Trust Fixes

- [x] Use agent token (aoc_ prefix) instead of user API key (oc_ prefix) for proxy auth
- [x] Set /etc/onecli-proxy-auth to mode 644 so non-root users can read it
- [x] Append OneCLI CA to existing CA bundles (handles Nix store symlinks)
- [x] Add fish shell proxy config via Home Manager shellInit
- [x] Guard onecli-seed-secrets in mise tasks for hosts without OneCLI
- [x] Add verbose diagnostics to onecli-check-proxy script

## Summary of Changes

Fixed three root causes preventing OneCLI proxy injection in containers:
1. Wrong API key type — gateway expects agent tokens (aoc_), not user keys (oc_)
2. CA trust — appended OneCLI CA directly to active CA bundles instead of using security.pki (which fails at Nix build time)
3. Fish shell — profile.d scripts aren't sourced by fish; moved proxy var setup to Home Manager's programs.fish.shellInit
