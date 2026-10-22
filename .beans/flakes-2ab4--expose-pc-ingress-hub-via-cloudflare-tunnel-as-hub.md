---
# flakes-2ab4
title: Expose pc ingress hub via Cloudflare tunnel as hub_pc.yjpark.org
status: completed
type: task
priority: normal
created_at: 2026-10-22T15:43:34Z
updated_at: 2026-10-22T15:54:41Z
---

pc's cloudflared tunnel (829deb72…) is remote-managed (config source: cloudflare), so the route is added through the Cloudflare API/dashboard, not Nix.

## Plan
- [ ] Tunnel ingress rule (before the 404 catch-all): hostname hub_pc.yjpark.org → http://localhost:80, originRequest.httpHostHeader = hub.pc.yjpark.org (host Caddy routes by Host; the HTTP block avoids TLS SNI/cert mismatch)
- [ ] DNS: CNAME hub_pc → 829deb72-9870-4b61-9120-bf748d85fbd2.cfargotunnel.com, proxied
- [x] Cloudflare Access self-hosted app on hub_pc.yjpark.org (hub page + /api/containers are unauthenticated), same policy as the ssh_* apps
- [x] Verify in browser

## Notes
- Blocked on re-authing the Cloudflare MCP with write scopes (tunnel config, DNS, Access apps); current session is read-only.
- Links/iframes on the hub point at *.pc.yjpark.org (ZeroTier IPs), so from outside only the hub page itself loads unless on ZeroTier.
- Underscore in a browser hostname: should work under the *.yjpark.org edge cert, but if not, fall back to hub-pc.yjpark.org.

## Progress (2026-10-22)
- Access app 64e6e1d0-5371-494a-b5f8-21e8499ca571 (self_hosted, reuses the two allow-email policies from ssh_pc), created first so the hub was never exposed without login.
- DNS 75f51f75f92ef98de71cb40cb79c1b93: proxied CNAME to the tunnel.
- Tunnel config v4: hub_pc rule inserted before the 404 catch-all; ssh_pc rule untouched.
- https://hub_pc.yjpark.org/ answers 302 to the Access login, edge TLS verifies (the underscore is fine).
- Origin not checked from yolo (no route to the host Caddy); needs a browser login to confirm.

## Summary of Changes
pc's remote-managed tunnel now serves https://hub_pc.yjpark.org (tunnel rule → http://localhost:80 with Host hub.pc.yjpark.org, proxied CNAME, Access app reusing the ssh_pc email policies). Confirmed working in the browser after Access login. No repo changes; everything lives in Cloudflare.
