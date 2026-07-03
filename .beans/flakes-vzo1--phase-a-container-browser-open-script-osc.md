---
# flakes-vzo1
title: 'Phase A: container browser-open script (OSC)'
status: completed
type: task
priority: normal
tags:
    - mcp
created_at: 2026-07-03T00:21:01Z
updated_at: 2026-07-03T00:30:16Z
parent: flakes-mqe9
---

Phase A of flakes-mqe9 — the **universal, detection-free** browser-open path.

Set the container's `$BROWSER` (and an `xdg-open` shim, since Claude Code / tools may call xdg-open directly rather than honoring `$BROWSER`) to a script that writes the authorize URL to the human's **controlling TTY** (`/dev/tty`, falling back to stderr — NOT stdout, which CC may capture) as:
- **OSC 52** — copy URL to the system clipboard (rides back through zellij/SSH to the terminal).
- **OSC 8** — clickable hyperlink.
- plain-text URL + **bell**.

Because these are terminal escape sequences on the live PTY, they land on whichever terminal the human is at (host desktop or Windows Terminal via WSL/SSH) with **no case detection**, and follow zellij detach/reattach. One click to open. This is the baseline that makes both access patterns work immediately.

## Tasks
- [x] `browser-open` script (writeShellApplication): URL from $1 (stdin fallback dropped — could block); OSC 52 + OSC 8 + plain + bell to /dev/tty (fallback stderr), single redirection
- [x] Wired `environment.variables.BROWSER` → script in `mcp-oauth-bridge.nix`
- [x] `xdg-open` shim (`lib.hiPrio` writeShellScriptBin) → browser-open, in systemPackages
- [x] Verified: nix-build; OSC 52 base64 round-trips to URL + OSC 8 URI + bell (od-level); no-arg/empty-stdin exit 1 no hang; full yolo toplevel evaluates (no collision); reviewed

## Summary of Changes

Phase A of the browser-open bridge — universal, detection-free.

**Files**
- `packs/nixos/container/mcp-scripts/browser-open.bash` (new): writes the authorize URL to the human's controlling TTY (`/dev/tty`, else `/dev/stderr` — never stdout, which CC captures) as OSC 52 clipboard + OSC 8 hyperlink + plain text + bell, in a single redirection. URL from `$1` only.
- `packs/nixos/container/mcp-oauth-bridge.nix`: builds it via `writeShellApplication`, sets `environment.variables.BROWSER`, and installs an `xdg-open` shim (`lib.hiPrio`) so tools that call xdg-open directly are also caught.

**Verified:** nix-build; OSC 52 base64 round-trips to the URL, OSC 8 URI correct, bell present (byte-level); no-arg and empty-stdin exit 1 without hanging; `bash -n`; full `yolo` toplevel evaluates (hiPrio resolves any xdg-utils collision). Review subagent confirmed escape-sequence spec-correctness, ST bytes, `set -e` safety of the sink probe, and URL quoting.

**Runtime caveat (documented):** OSC 52 clipboard and OSC 8 hyperlink passthrough are **best-effort under zellij** (version/clipboard-config dependent). The script degrades gracefully — the printed plain-text URL is the guaranteed path. No code change needed.

**Note:** Phase A makes the URL *visible/clickable* everywhere but is not zero-click and does not itself deliver the OAuth *callback* — the callback forwards (host socat / WSL LocalForward) live in flakes-ok62 / flakes-q3l5, and zero-click auto-open is Phase B there.
