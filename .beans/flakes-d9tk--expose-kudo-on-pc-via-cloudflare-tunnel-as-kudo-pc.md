---
# flakes-d9tk
title: Expose kudo on pc via Cloudflare tunnel as kudo_pc.yjpark.org
status: draft
type: task
priority: low
created_at: 2026-10-22T15:54:41Z
updated_at: 2026-10-22T15:54:41Z
---

Same pattern as flakes-2ab4 (hub_pc): Access app reusing the ssh_pc email policies (create first), proxied CNAME to pc's tunnel 829deb72-9870-4b61-9120-bf748d85fbd2, and a tunnel rule before the 404 catch-all.

Wait until kudo and the hub are working end to end. Then pick the origin: the kudo hub (services.hub, bound to 10.100.0.1:15400 and 172.22.1.9:15400, see mixins/nixos/services/kudo-hub.nix) or a Caddy route, and check whether kudo needs websockets or non-browser clients. A non-browser client needs an Access service token or a bypass policy.
