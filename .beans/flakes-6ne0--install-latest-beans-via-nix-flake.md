---
# flakes-6ne0
title: Install latest beans via nix flake
status: completed
type: task
priority: normal
created_at: 2026-04-04T17:52:30Z
updated_at: 2026-06-29T14:21:21Z
---

Add beans (edger-dev/beans) as a flake input and install it as a home-manager package, replacing or supplementing the current beans installation.

## Plan

### Investigation (changes the approach)

- The bean assumed a flake input `edger-dev/beans`. **That repo 404s** (private or nonexistent; no GitHub auth in this container). The real upstream is **`github.com/hmans/beans`** (from the binary's Go module path).
- `hmans/beans` is public but has **no flake.nix**, so it can't be a flake input directly.
- Building from source is a **two-stage pnpm + Go build**: `internal/web/embed.go` has `//go:embed dist/*` which requires a pre-built SvelteKit frontend (`pnpm build` → copy into `internal/web/dist/`) before `go build`. That needs two content hashes (pnpmDeps + goModules vendorHash) and is high-risk to converge unattended.
- **hmans/beans publishes prebuilt goreleaser binaries.** Latest stable = **v0.4.2**, per-platform tarballs (Linux x86_64/arm64, Darwin x86_64/arm64). The Linux binary is **static** (`not a dynamic executable`) and runs (`beans 0.4.2`). License: Apache-2.0.
- The public release ships **only `beans`** (CLI + `beans tui` subcommand). `beans-serve` (web UI, embeds the frontend) is **not** published and is **not** a subcommand of `beans` v0.4.2 (`beans serve` → unknown command). The current imperative install (from a private dev build) has all three: `beans`/`beans-serve`/`beans-tui`.

### Decision

Package the **prebuilt v0.4.2 `beans` release binary** as a home-manager package via `fetchurl` (per-platform, hashes from the release `checksums.txt`). This is robust and verifiable, and honors the bean's intent (manage beans declaratively via nix) better than the impossible flake-input or the fragile source build.

**Scope note:** this *supplements* — it adds nix-managed `beans` (CLI + TUI). It does **not** remove the imperative `~/.local/bin/{beans,beans-serve,beans-tui}` and does **not** provide `beans-serve` (web UI), which the public release doesn't publish. Packaging `beans-serve` would need the source build → separate follow-up.

### Steps
- [x] Added `packs/home/common/packages/beans.nix` (prebuilt v0.4.2, per-platform fetchurl) + `home.packages` entry
- [x] Built via nix-build; binary runs (`beans 0.4.2`, `tui` subcommand, `list`); `homeConfigurations.yj` now contains beans-0.4.2
- [x] Reviewed (subagent verified all 4 hashes vs upstream checksums, static-binary + darwin-signing concerns cleared) + committed

## Summary of Changes

Added `packs/home/common/packages/beans.nix`: a home-manager module that installs the **prebuilt v0.4.2 `beans` release binary** from `github.com/hmans/beans` via per-platform `fetchurl` (x86_64/aarch64 × linux/darwin), hashes pinned from the release `checksums.txt`, added to `home.packages`.

**Deviation from the original spec (documented in Plan):** the bean named a flake input `edger-dev/beans` — that repo is inaccessible (404/private, no auth here) and the real upstream `hmans/beans` has no flake. Building from source is a two-stage pnpm+Go build (embedded SvelteKit frontend). The prebuilt release binary is the robust, verifiable path and matches the intent (declarative nix-managed beans).

**Verified:** `nix-build` succeeds; the binary runs (`beans 0.4.2`, `beans tui`, `beans list`); `homeConfigurations.yj.config.home.packages` contains beans-0.4.2; activation package evaluates. Review subagent confirmed all four asset hashes against upstream checksums and cleared static-binary/darwin-signing concerns.

**Scope / follow-up:** supplements (does not remove) the imperative `~/.local/bin/{beans,beans-serve,beans-tui}`. `beans-serve` (web UI) is not in the public release; packaging it from source is tracked in follow-up bean flakes-qe0o. PATH precedence: if `~/.local/bin` shadows the nix beans, remove the imperative copy to use v0.4.2.
