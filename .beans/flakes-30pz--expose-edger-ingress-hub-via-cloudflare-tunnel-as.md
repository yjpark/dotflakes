---
# flakes-30pz
title: Expose edger ingress hub via Cloudflare tunnel as hub_edger.yjpark.org
status: completed
type: task
created_at: 2026-10-22T16:03:02Z
updated_at: 2026-10-22T16:03:02Z
---

Same as flakes-2ab4 (hub_pc), on edger's remote-managed tunnel f62c3a91-d7b5-48c3-921d-f22e0f0cd0e9.

- [x] Access app b6f86432-eb4c-4b66-b52e-602e893d3cde (self_hosted, the ssh_* allow-email policies), created first
- [x] DNS 4b4a7de5ae2c02ef1c081c0d13e25118: proxied CNAME to the tunnel
- [x] Tunnel config v2: hub_edger → http://localhost:80 with httpHostHeader hub.edger.yjpark.org, before the 404 catch-all; ssh_edger untouched
- [x] Verified: public URL 302 to the Access login, edge TLS verifies; origin (http, Host hub.edger.yjpark.org) answers 200

## Summary of Changes
https://hub_edger.yjpark.org now serves edger's hub page behind Cloudflare Access. No repo changes; everything lives in Cloudflare.
