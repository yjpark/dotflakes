---
# flakes-8itl
title: Configure & run ZeroClaw (config, secrets, service)
status: draft
type: task
tags:
    - tools
created_at: 2026-06-29T14:28:57Z
updated_at: 2026-06-29T14:28:57Z
parent: flakes-qbvb
---

Follow-up from flakes-kj17, which installed the ZeroClaw **binaries** (v0.8.2) via nix (`packs/home/common/packages/zeroclaw.nix`). This bean covers actually **running/configuring** ZeroClaw, which needs user decisions and secrets and so was deferred from the autonomous install.

ZeroClaw is a self-hosted autonomous AI assistant runtime: LLM providers (Anthropic/OpenAI/Ollama/...), channels (Discord/Telegram/Matrix/email/CLI), tools (shell/browser/http), configured via `~/.zeroclaw/config.toml`.

## Decisions needed
- [ ] Which LLM provider(s) + API keys — manage secrets via sops-nix (this repo's pattern), not plaintext config
- [ ] Which channels/integrations to enable, and the autonomy level (this thing can run shell/tools — scope carefully)
- [ ] Run mode: on-demand CLI (`zeroclaw`/`zerocode`) vs. an always-on service. Upstream ships a **NixOS module** (system service), not a home-manager service — decide host(s) and whether to use the upstream module or a home-manager systemd user service
- [ ] Which machines should run it (currently the binary is in the common home profile → all profiles incl. containers; consider narrowing to a host mixin)

## Tasks (once decided)
- [ ] Declarative `config.toml` (home-manager `home.file` or xdg) with secrets wired via sops-nix
- [ ] If service: import upstream NixOS module on the chosen host, or define a user service
- [ ] Verify a minimal end-to-end run (one provider, CLI channel)

## Notes
- The release tarball also ships a `web/dist/` dashboard copy; the static binary likely embeds its UI. If the web dashboard fails to find assets at runtime, package `web/dist/` alongside and point ZeroClaw at it.
- To track latest: bump `version` + `sha256` in `zeroclaw.nix` from the release `SHA256SUMS`.
