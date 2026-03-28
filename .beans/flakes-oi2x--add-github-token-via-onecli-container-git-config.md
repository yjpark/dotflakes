---
# flakes-oi2x
title: Add GitHub token via OneCLI + container git config
status: completed
type: task
priority: normal
created_at: 2026-03-27T12:20:41Z
updated_at: 2026-03-28T05:20:15Z
order: zzk
---

Add GitHub fine-grained token to OneCLI for transparent auth injection into yolo container. Add container-specific git config to rewrite SSH URLs to HTTPS.

## Summary of Changes

1. **`mixins/nixos/services/onecli.nix`** — Added `GITHUB_TOKEN` secret config with `*.github.com` host pattern and `Authorization: token {value}` injection
2. **`mixins/home/container/git.nix`** — New file: rewrites SSH GitHub URLs to HTTPS (routes through OneCLI proxy) and sets `GIT_TERMINAL_PROMPT=0`
3. **`mixins/nixos/services/secrets/onecli-secrets.txt`** — User needs to add real token via `sops`
