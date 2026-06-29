---
# flakes-k391
title: Setup quartz to preview and publish oxide projects
status: draft
type: task
priority: normal
tags:
    - tools
created_at: 2026-03-14T01:58:13Z
updated_at: 2026-06-29T14:29:57Z
order: k
---

## Blocked — needs spec (triaged 2026-06-29, night shift)

The bean has no body and the approach can't be determined without guessing on several independent axes. Context found: 'oxide projects' most likely refers to **markdown-oxide** notes (the Obsidian-style markdown PKM enabled in [[flakes-7ih3]] via the `markdown_oxide` LSP — but no vault path is configured anywhere in the repo).

**Quartz** (https://quartz.jzhao.xyz) is a static-site generator that publishes a folder of Obsidian/markdown notes. It's structured as a per-content **project scaffold** (clone quartz, put markdown in `content/`, `npx quartz build/preview`), not a home-manager package — so this is a project/workflow setup, not a dotfiles config change.

### Open questions blocking implementation
1. **Content source:** which markdown directory/vault are the 'oxide projects'? Where does it live (path / separate git repo / the private/ dir)?
2. **Repo location:** should the Quartz project live in this flakes repo, a sibling repo, or inside the notes vault?
3. **Publish target:** GitHub Pages? Cloudflare Pages? The existing host Caddy ingress (`*.${host}.yjpark.org`, see `mixins/nixos/services/incus-ingress.nix`)? Cloudflared tunnel? This drives the whole 'publish' half.
4. **Preview:** local `npx quartz build --serve` is generic; fine once content path is known.

### Proposed approach (once unblocked)
- Scaffold Quartz pointing `content/` at the vault (or symlink); add a `mise`/just task for `preview`; pick a publish target and add a build+deploy task (or a NixOS/cloudflared service if self-hosting). Optionally add the `quartz`/node toolchain to a dev shell.

Moved to draft so it leaves the ready queue until the content source + publish target are decided.
