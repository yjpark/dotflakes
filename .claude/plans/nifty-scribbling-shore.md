# Plan: Fix llm-agents evaluation error in container builds

## Context

After merging `home-hosts.nix` and `home-containers.nix` into `home-configs.nix`, container builds fail with `attribute '__functor' missing` from `llm-agents`' blueprint. The user split `modules/home/packages/ai.nix` into mixin-specific files (`mixins/home/{host,container,gui}/ai.nix`), but `modules/home/programs/claude/settings.nix` still references `flake.inputs.llm-agents` in shared modules — so the container still triggers the error.

## Root Cause

`modules/home/programs/claude/settings.nix` (line 8) sets:
```nix
package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
```

This is in `self.homeModules.default`, imported by BOTH `yjpark.nix` (host) and `yj.nix` (container). Any evaluation of `flake.inputs.llm-agents` triggers blueprint's `__functor` error in the container's activation flake.

## Fix

1. **`modules/home/programs/claude/settings.nix`** — Remove the `package` line. Keep `enable = true` and settings.

2. **`mixins/home/host/ai.nix`** — Add `programs.claude-code.package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;` (it already has the `with llm-agents.packages...` scope).

3. **`mixins/home/container/ai.nix`** — Add the same `programs.claude-code.package` line (it also has the `with llm-agents.packages...` scope).

This moves ALL `llm-agents` references out of shared modules into mixin-specific files. If the container's `llm-agents` evaluation still fails, the user can remove it from just the container mixin without affecting the host.

## Verification

- `just show` — confirm all homeConfigurations still appear
- `just activate-home` — host activation works
- Container activation for `yj@yolo` — no longer hits the shared module's llm-agents reference

## Note

If the container STILL fails after this fix, it means `llm-agents` itself is fundamentally broken in the container's evaluation context (the `/nix/store/...-nixos-unified-activate-flake`). In that case, the container mixin's `ai.nix` would also need to stop using `llm-agents` and either use `pkgs.claude-code` from nixpkgs or remove the AI packages from containers entirely.
