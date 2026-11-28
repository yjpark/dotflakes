---
# flakes-r2mx
title: Route kudo context mirror through host proxy
status: in-progress
type: bug
created_at: 2026-11-28T14:30:00Z
updated_at: 2026-11-28T14:30:00Z
---

Direct TLS connections to the R2 endpoint fail from yolo, while the host mihomo proxy at `10.100.0.1:21102` reaches R2 successfully. Deploy kudo's mirror-specific `KINORA_MIRROR_PROXY` support without setting general proxy variables or changing OneCLI policy. Done when edger and pc Home Manager configurations build and activate, the waker and workers synchronize with R2 without TLS errors, a cross-machine context write becomes visible, and ordinary OneCLI behavior remains unchanged.
