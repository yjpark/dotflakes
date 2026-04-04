---
# flakes-68h7
title: Host Caddy LAN proxy for Incus container services
status: completed
type: feature
priority: normal
created_at: 2026-03-22T14:58:58Z
updated_at: 2026-03-23T07:48:29Z
order: m
---

Add host-level Caddy reverse proxy to expose Incus container services to ZeroTier LAN via *.hostname.yjpark.org with Let's Encrypt certs (Cloudflare DNS-01). Domain pattern: yolo-8080.edger.yjpark.org → http://10.100.0.100:8080.

## Summary of Changes

Modified `mixins/nixos/host/incus-ingress.nix`:
- Added `pkgs.caddy.withPlugins` with the Cloudflare DNS plugin (hash pinned to `sha256-bL1cpMvDogD/...`)
- Added Caddyfile generation: HTTPS + HTTP fallback blocks, per-container `host_regexp` matchers
- Added `sops.secrets."cloudflare-caddy-env"` declaration pointing to `./secrets/cloudflare-caddy.txt`
- Added `systemd.services.caddy.serviceConfig.EnvironmentFile` for the SOPS secret path
- Added `services.firewalld.zones.public.services = ["http" "https"]`

Pending user action: create `mixins/nixos/host/secrets/cloudflare-caddy.txt` as a SOPS-encrypted dotenv file containing `CLOUDFLARE_API_TOKEN=<token>`.
