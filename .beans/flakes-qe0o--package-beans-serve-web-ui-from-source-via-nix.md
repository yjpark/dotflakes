---
# flakes-qe0o
title: Package beans-serve (web UI) from source via nix
status: draft
type: task
tags:
    - tools
created_at: 2026-06-29T14:21:03Z
updated_at: 2026-06-29T14:21:03Z
parent: flakes-qbvb
---

The nix package added in flakes-6ne0 installs the prebuilt `beans` release binary (CLI + `beans tui`). The public release does **not** publish `beans-serve` (the web UI / GraphQL server, ~59MB because it embeds the SvelteKit frontend), so the `bw = beans-serve` fish abbr still relies on the imperative `~/.local/bin/beans-serve`.

To package `beans-serve` declaratively requires building from source (`github.com/hmans/beans`), which is a two-stage build:

1. Frontend: `frontend/` is SvelteKit + pnpm. `pnpm install` + `pnpm build`, output copied into `internal/web/dist/` (consumed by `//go:embed dist/*` in `internal/web/embed.go`). Needs a `pnpmDeps` fixed-output hash.
2. Backend: `go build ./cmd/beans-serve` (and optionally `./cmd/beans`, `./cmd/beans-tui`) via `buildGoModule` with a `vendorHash`. Note `internal/graph/generated.go` appears committed, but `mise.toml`'s build runs `go generate ./...` (gqlgen) first — confirm whether codegen is needed or the committed output suffices.

## Open questions

- [ ] Is the web UI (`beans-serve`) actually still used, or has the workflow moved to TUI / external beans server? If unused, scrap this.
- [ ] Prefer building all three from source (replacing the prebuilt-binary package in flakes-6ne0 for consistency) vs. keeping prebuilt `beans` + source-built `beans-serve`?

## Tasks (if pursued)

- [ ] Frontend derivation (pnpm) -> dist
- [ ] buildGoModule with vendorHash, embedding the built frontend
- [ ] Wire into home.packages; update `bw`/`bt` abbrs as needed; drop imperative `~/.local/bin/beans*`
