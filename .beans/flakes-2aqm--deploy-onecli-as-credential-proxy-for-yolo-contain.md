---
# flakes-2aqm
title: Deploy OneCLI as credential proxy for yolo container
status: in-progress
type: feature
priority: normal
created_at: 2026-03-23T03:40:59Z
updated_at: 2026-03-23T03:43:06Z
---

Set up OneCLI (MITM proxy) on edger host to inject API keys for agents running in the yolo Incus LXC container. Agents get placeholder keys; OneCLI injects real credentials at the network layer.

## Tasks

- [x] Create mixins/nixos/services/onecli.nix (OCI containers + seeder service)
- [ ] Create mixins/nixos/services/secrets/onecli-secrets.txt (sops-encrypted)
- [x] Modify configurations/nixos/edger/imports.nix (enable onecli)
- [x] Modify mixins/home/ai/tools/claude-mcp-add-context7.bash (use placeholder key)
- [x] Modify mixins/home/host/linux/scripts/incus/incus-launch-yolo.bash (push CA cert)
