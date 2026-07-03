---
# flakes-q3l5
title: 'WSL: callback forward + wslview auto-open'
status: todo
type: task
tags:
    - mcp
created_at: 2026-07-03T00:21:01Z
updated_at: 2026-07-03T00:21:01Z
parent: flakes-mqe9
---

WSL/Windows (Case 2) side of flakes-mqe9. Chain: Windows → WSL (Ubuntu, home-manager-managed) → `ssh host` → `incus exec` → container. Fully declarative because WSL is managed by this repo; `wslview` (wslu) / `cmd.exe /c start` opens the Windows default browser from WSL.

## Callback (needed for Phase A too)
- [ ] WSL `programs.ssh.matchBlocks.<host>.localForwards` = `LocalForward 3118 10.100.0.100:3118`. Windows `localhost:3118/callback` → WSL localhost forwarding → WSL ssh -L → host → container Caddy bridge → CC. (Confirm WSL2 `localhostForwarding=true`, the default.)

## Phase B — zero-click auto-open
- [ ] WSL open-listener that runs `wslview <url>` (ensure `wslu` installed in the WSL home profile).
- [ ] WSL ssh `RemoteForward 10.100.0.1:OPEN localhost:OPEN` (bind host bridge IP) so container→`gateway:OPEN`→tunnel→WSL listener→`wslview`.
- [ ] Host sshd `GatewayPorts clientspecified` (the one non-flake host tweak) so the -R can bind the bridge IP.
- [ ] Attach wrapper detects `SSH_CONNECTION` and injects `BROWSER_ROUTE` accordingly; OSC (Phase A) stays the fallback.
