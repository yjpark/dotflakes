---
# flakes-gb22
title: Ingress hub on p2, exposed as hub_p2.yjpark.org
status: draft
type: task
priority: low
created_at: 2026-10-22T16:07:28Z
updated_at: 2026-10-22T16:07:28Z
---

p2 has no hub yet: mixins/nixos/services/incus-ingress is only imported on pc and edger. Deferred on 2026-10-22.

## What it takes
- [ ] Make `ingress.containers` in the incus-ingress mixin overridable (it hardcodes onecli/searxng/yolo); p2 gets `[]` unless it runs containers
- [ ] Import incus-ingress in nixos/hosts/p2/imports.nix; add p2 to `ingress.sites` (packs/nixos/host/ingress.nix)
- [ ] DNS: `*.p2.yjpark.org` A record → 172.22.1.5 (ZeroTier, unproxied), like pc/edger
- [ ] Switch p2; check hub.p2.yjpark.org over ZeroTier
- [ ] Cloudflare, same as flakes-2ab4: Access app (ssh_* allow-email policies) first, proxied CNAME hub_p2 → p2's tunnel, tunnel rule → http://localhost:80 with httpHostHeader hub.p2.yjpark.org

## Notes
- The only hub service on p2 today is clash (`ingress.services` evaluates to ["clash"]); incus is enabled.
- The cloudflare-caddy secret (mixins/nixos/services/secrets/cloudflare-caddy.txt) is already encrypted for p2's age key.
- p2 is a CN host: Caddy needs the clash proxy env for Let's Encrypt (mixins/nixos/cn/proxy-env.nix already covers it).
