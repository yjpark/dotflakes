---
# flakes-qbvb
title: Container-first infrastructure
status: todo
type: epic
priority: normal
created_at: 2026-04-05T06:23:27Z
updated_at: 2026-04-05T06:23:38Z
---

Migrate services to containers, isolate host, restructure Nix config.

## IP Scheme

```
10.100.0.1       host (bridge)
10.100.0.2+      infra containers
  .002           onecli
  .003           searxng
10.100.0.100+    agent containers
  .100           yolo
  .101           spacebot
  .102           hermes
10.100.0.200+    scratch
  .200           ubuntu
```

## Architecture

- Host becomes thin bridge: Caddy ingress, dnsmasq, SOPS secrets, onecli-seeder
- OneCLI moves to its own container
- SearXNG in its own container
- Container→host traffic blocked (except DHCP/DNS) via nftables
- Container↔container unrestricted on bridge
- Secret flow: Host SOPS → seeder calls OneCLI API at .002 → pushes proxy-auth/CA to agent containers
- CA cert injection made declarative via security.pki.certificateFiles
- Drop nixos-unified for raw flake-parts (separate host/container config namespaces)
