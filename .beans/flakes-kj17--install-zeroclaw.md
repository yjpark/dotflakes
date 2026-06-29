---
# flakes-kj17
title: Install Zeroclaw
status: completed
type: task
priority: normal
created_at: 2026-04-04T18:41:32Z
updated_at: 2026-06-29T14:29:12Z
---

Install Zeroclaw (https://github.com/zeroclaw-labs/zeroclaw) — evaluate and set up in the environment.

## Plan

### Evaluation (research + verified, 2026-06-29)
ZeroClaw (`github.com/zeroclaw-labs/zeroclaw`, MIT/Apache-2.0) is a single-binary **Rust** self-hosted autonomous AI assistant runtime (LLM providers + channels + tools; TOML config at `~/.zeroclaw/config.toml`). Latest release **v0.8.2**.

Availability (verified): in nixpkgs as `zeroclaw` but **stale (0.5.1)**; upstream flake has `packages.<sys>.zeroclaw` (but compiles a large Rust workspace, and `packages.default` is the Rust toolchain, no `apps`); **prebuilt release binaries + SHA256SUMS** for all platforms.

### Decision
Package the **prebuilt v0.8.2 release binary** via `fetchurl` (same pattern as `beans.nix` / flakes-6ne0). This gives the latest version with **no heavy Rust build and no new flake input** — strictly better than the stale nixpkgs build and lighter than building the upstream flake from source. Use the **musl (static)** linux builds (no patchelf/loader concerns on NixOS).

Platforms: x86_64-linux, aarch64-linux (musl), aarch64-darwin. No x86_64-darwin asset is published → unsupported (throw).

**Scope:** install the `zeroclaw` (+ `zerocode`) binaries only. Runtime 'setup' (config.toml, API-key secrets, optional systemd service) needs user decisions → deferred to a follow-up. The web dashboard ships a `web/dist/` copy in the tarball; the static binary most likely embeds its UI, so only the binaries are installed (caveat noted).

### Steps
- [x] Added `packs/home/common/packages/zeroclaw.nix` (prebuilt v0.8.2 musl/darwin fetchurl) + home.packages
- [x] nix-build OK; `zeroclaw 0.8.2` runs (zeroclaw + zerocode installed); present in homeConfigurations.yj
- [x] Self-reviewed (same verified pattern as beans.nix flakes-6ne0); committed; follow-up bean created for runtime config/secrets/service

## Summary of Changes

Added `packs/home/common/packages/zeroclaw.nix`: home-manager package installing the **prebuilt ZeroClaw v0.8.2** release binaries (`zeroclaw` + `zerocode`) via per-platform `fetchurl` (x86_64-linux/aarch64-linux musl-static, aarch64-darwin), hashes pinned from the release `SHA256SUMS`.

**Why prebuilt:** nixpkgs `zeroclaw` is stale (0.5.1) and the upstream flake compiles a large Rust workspace; the prebuilt static binary gives the latest with no heavy build and no new flake input (same pattern as beans, flakes-6ne0).

**Verified:** `nix-build` succeeds; `zeroclaw 0.8.2` runs; both binaries installed; present in `homeConfigurations.yj`.

**Scope:** binaries only. Runtime setup (config.toml, API-key secrets via sops-nix, optional service, host targeting) is deferred to follow-up **flakes-8itl** — it needs user decisions and secrets, inappropriate for autonomous setup.
