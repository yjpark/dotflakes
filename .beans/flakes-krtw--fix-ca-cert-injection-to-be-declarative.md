---
# flakes-krtw
title: Fix CA cert injection to be declarative
status: todo
type: task
created_at: 2026-04-05T06:23:54Z
updated_at: 2026-04-05T06:23:54Z
parent: flakes-qbvb
---

Replace manual /etc/ssl/certs mutation with security.pki.certificateFiles. Seeder pushes CA to a known path, NixOS handles cert bundle integration.
