---
# flakes-krtw
title: Fix CA cert injection to be declarative
status: in-progress
type: task
priority: normal
created_at: 2026-04-05T06:23:54Z
updated_at: 2026-04-05T13:09:53Z
parent: flakes-qbvb
---

Replace manual /etc/ssl/certs mutation with security.pki.certificateFiles. Seeder pushes CA to a known path, NixOS handles cert bundle integration.
