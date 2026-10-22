---
# flakes-xv5g
title: Reach pc ingress services without ZeroTier
status: draft
type: feature
priority: low
created_at: 2026-10-22T15:54:41Z
updated_at: 2026-10-22T15:54:41Z
---

hub_pc.yjpark.org works off ZeroTier, but the links on the hub page (`<svc>.pc.yjpark.org`, `<c>-<port>.pc.yjpark.org`) resolve to pc's ZeroTier IP 172.22.1.9 (the `*.pc.yjpark.org` A record isn't proxied), so they don't load from outside.

## Constraints
- Universal SSL covers only `*.yjpark.org` (one level). Proxying `*.pc.yjpark.org` would need Advanced Certificate Manager or Total TLS, and would take those names away from ZeroTier-direct use.
- pc's tunnel is remote-managed, so ingress rules live in Cloudflare, not in Nix.
- Container ports are found at runtime (hub API), so no fixed list exists for them.

## Options
1. **Flat public names**, e.g. `<svc>_pc.yjpark.org` / `<c>-<port>_pc.yjpark.org`, covered by `*.yjpark.org`. One wildcard tunnel rule (or one per service) to Caddy on :80. Caddy also matches the `_pc` form and maps it to the same routes. The hub page picks public or ZeroTier URLs based on the hostname it was loaded from. Needs a wildcard DNS record or a record per name, and Access on each name (or one wildcard Access app).
2. **Move the tunnel to locally-managed config** (services.cloudflared ingress in Nix), with rules generated from ingress.services. Fully declarative, but static. Container ports would still need a wildcard (option 1).
3. **Path-based through the hub** (`hub_pc.yjpark.org/s/<name>/`): no DNS or certificates to set up, but breaks apps that expect to sit at the root path (this was dropped before in flakes-i4ol).

Leaning toward 1. Open question: is `*.yjpark.org` already used by anything else?
