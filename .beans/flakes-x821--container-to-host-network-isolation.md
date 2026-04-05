---
# flakes-x821
title: Container-to-host network isolation
status: todo
type: task
created_at: 2026-04-05T06:23:56Z
updated_at: 2026-04-05T06:23:56Z
parent: flakes-qbvb
---

Add nftables INPUT rules on incusbr0 to block container→host traffic except DHCP (67/68) and DNS (53/5354). Container↔container traffic via FORWARD chain stays unrestricted.
