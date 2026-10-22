---
# flakes-tnjz
title: Bootstrap home-manager on x1 WSL (Ubuntu)
status: todo
type: task
created_at: 2026-10-22T15:21:34Z
updated_at: 2026-10-22T15:21:34Z
---

First activation of the yjpark home profile on the Windows x1's WSL Ubuntu, so the MCP OAuth callback forward (flakes-q3l5) and the rest of the CLI setup land there.

Prepared in the repo:
- `yjpark@wsl` home config = `home/yjpark-cli.nix` (host packs, no GUI pack, so no niri/VSCode/claude-desktop builds); `mise run _activate-home` / `nix run` picks it when `$WSL_DISTRO_NAME` is set.
- `flake.nix` `nixConfig` adds the numtide cache (cache.numtide.com) for llm-agents; Nix only honours it for trusted users and asks once before using it.

## Todo
- [ ] One-time root step on Ubuntu (not manageable by home-manager): trust the user so the flake's cache is honoured. Upstream installer: append `trusted-users = root yjpark` to `/etc/nix/nix.conf`; Determinate installer: put it in `/etc/nix/nix.custom.conf`. Then `sudo systemctl restart nix-daemon`. Make sure `experimental-features = nix-command flakes` is on.
- [ ] Confirm the WSL user is `yjpark` (`me.username` sets home to /home/yjpark).
- [ ] Clone the repo, `nix run` (answer y to the cache prompts, or pass `--accept-flake-config`); check llm-agents packages are fetched, not built.
- [ ] Continue with flakes-q3l5 end-to-end OAuth test.
