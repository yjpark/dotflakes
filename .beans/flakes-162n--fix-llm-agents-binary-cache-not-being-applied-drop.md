---
# flakes-162n
title: Fix llm-agents binary cache not being applied; drop dead ai trail
status: completed
type: bug
priority: normal
created_at: 2026-10-06T05:45:03Z
updated_at: 2026-10-06T05:47:21Z
---

cache.numtide.com was whitelisted via extra-trusted-substituters but never added to substituters, so all llm-agents packages built from source. Also mixins/home/trails/ai.nix was never imported.

## Summary of Changes

**Root cause.** `github:numtide/llm-agents.nix` does declare a binary cache in its
`nixConfig` (`extra-substituters = [ "https://cache.numtide.com" ]`), and that cache is
fully populated — all 7 referenced packages return HTTP 200 for their narinfo. But Nix
ignores a flake's `nixConfig` unless the setting is whitelisted *or* `accept-flake-config`
is on, so every command printed:

    warning: ignoring untrusted flake configuration setting 'extra-substituters'

`packs/nixos/common/settings/nix/llm-agents.nix` used `extra-trusted-substituters`, which
only permits a client to *opt in* to that substituter; it never joins the real
`substituters` list. `nix show-config` confirmed cache.numtide.com was absent from
`substituters`, so llm-agents packages were built from source.

Measured cost on codex + ck + beads:
- before: 11 derivations built (Rust codex, Go toolchain, dolt, ck pulling onnxruntime + openvino)
- after:  0 built, 1.1 GiB fetched

**Changes.**
1. `packs/nixos/common/settings/nix/llm-agents.nix`: `nix.settings.extra-trusted-substituters`
   -> `nix.settings.extra-substituters`. The `extra-trusted-public-keys` line was already
   correct and is unchanged.
2. Deleted `mixins/home/trails/ai.nix` (and with it the now-empty `mixins/home/trails/`).
   Nothing imported it — mixins are only reachable by explicit import, and the auto-discovery
   in `flake/home-configs.nix` and `flake/activate-home.nix` only scans `mixins/home/hosts`
   and `mixins/home/containers`. It held the only references to `ck`, `beads`, and a pinned
   `dolt` override, which is why llm-agents felt mostly unused.

**Verification.**
- `nix fmt` reported the file already correctly formatted.
- Generated nix.conf for host `pc` now contains
  `extra-substituters = https://cache.numtide.com`, with `substituters` keeping the
  CN mirror ordering from `mixins/nixos/lan/cn/mirrors.nix` (tuna, then cache.nixos.org,
  then numtide appended).
- Dry-run against the live package set with the post-switch substituter list: nothing to build.

**Still live from llm-agents** (so the input is still needed): `claude-code` (also
`programs.claude-code.package`), `agent-browser`, `rtk`, `opencode`, `codex` via the
autowired `packs/home/common/ai/llm-agents.nix`; plus `opencode` and `claude-code` in
`mixins/home/containers/spacebot.nix`.

**Notes.**
- This is a system-level setting, so it needs `mise run _switch-host` per machine to take effect.
- The "ignoring untrusted flake configuration setting" warning will still appear. It is now
  harmless and redundant: the cache comes from our own nix.conf rather than the flake's nixConfig.
- `trusted-substituters` is now empty where it previously listed cache.numtide.com. Not a
  regression — opting in is unnecessary once it is a default substituter.
