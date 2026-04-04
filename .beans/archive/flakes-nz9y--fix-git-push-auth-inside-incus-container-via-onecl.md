---
# flakes-nz9y
title: Fix git push auth inside Incus container via OneCLI proxy
status: completed
type: bug
priority: normal
created_at: 2026-03-28T13:45:09Z
updated_at: 2026-03-28T13:45:24Z
---

git push inside the container failed with 'could not read Username for https://github.com: terminal prompts disabled'. Two root causes were identified and fixed.

## Summary of Changes

### Problem
`git push` inside the Incus container failed with:
```
fatal: could not read Username for 'https://github.com': terminal prompts disabled
```

The OneCLI MITM proxy was correctly configured and the proxy was being used, but two issues prevented authentication from working.

### Root Cause 1: gh credential helper override
Home Manager's `programs.gh` module auto-registers `gh auth git-credential` as a git credential helper for github.com. The `lib.mkForce ""` in `git.nix` cleared the helper list, but gh re-added its helper *after* the clear. Git would call `gh auth git-credential`, which tried the placeholder `GH_TOKEN=onecli-managed`, failed, then fell back to terminal prompt.

**Fix:** `programs.gh.gitCredentialHelper.enable = false` in `mixins/home/container/git.nix`

### Root Cause 2: Wrong auth format for GitHub's git HTTP endpoint
OneCLI was injecting `Authorization: token <PAT>` which works for GitHub's REST API (`api.github.com`) but NOT for GitHub's git smart HTTP endpoint (`github.com`). The git endpoint requires Basic auth: `Authorization: Basic base64(x-access-token:<PAT>)`.

**Fix:** Added `encoding = "basic-auth"` field to `GITHUB_TOKEN` secret config in `mixins/nixos/services/onecli.nix`. The seeder script base64-encodes `x-access-token:<value>` when this encoding is set, and the `valueFormat` was changed to `Basic {value}`.

### Key diagnostic commands
- `GIT_CURL_VERBOSE=1 git push` — revealed git wasn't sending `Proxy-Authorization` (fixed by `http.proxyAuthMethod = basic`)
- OneCLI gateway logs (`podman logs onecli`) — confirmed MITM + injection was happening but GitHub returned 401
- Certificate issuer in TLS handshake — confirmed OneCLI CA vs real cert (MITM vs tunnel)

### Files modified
- `mixins/home/container/git.nix` — disabled gh credential helper, removed extraHeader workaround, added `proxyAuthMethod = basic`
- `mixins/nixos/services/onecli.nix` — changed GITHUB_TOKEN to Basic auth format with base64 encoding at seed time
