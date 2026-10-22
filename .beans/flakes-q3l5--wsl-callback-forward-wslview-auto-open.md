---
# flakes-q3l5
title: 'WSL: callback forward + wslview auto-open'
status: in-progress
type: task
priority: normal
tags:
    - mcp
created_at: 2026-07-03T00:21:01Z
updated_at: 2026-10-22T15:37:09Z
parent: flakes-mqe9
blocked_by:
    - flakes-i4ol
---

WSL/Windows (Case 2) side of flakes-mqe9. Chain: Windows → WSL (Ubuntu, home-manager-managed) → `ssh host` → `incus exec` → container. Fully declarative because WSL is managed by this repo; `wslview` (wslu) / `cmd.exe /c start` opens the Windows default browser from WSL.

## Callback (needed for Phase A too)
- [x] `programs.ssh.matchBlocks.mcp-oauth-pc` (`Host pc pc.* desktop desktop.* 172.22.1.9`, `LocalForward 3118 10.100.0.100:3118`) in `packs/home/host/common/mcp-oauth-forward.nix` — host profiles only (in containers CC itself listens on 3118). Windows `localhost:3118/callback` → WSL localhost forwarding → WSL ssh -L → pc → yolo `mcp-oauth-bridge` (socat eth0:3118 → 127.0.0.1:3118) → CC.
- [x] Verified: generated ssh config for `yjpark` has the LocalForward, `yj@yolo` does not; in yolo, `curl 10.100.0.100:3118/callback?...` reaches a stand-in `127.0.0.1:3118` listener through the bridge.
- [x] (2026-10-22: Cloudflare sign-in from the x1 worked end to end with a manual `ssh -L 3118:10.100.0.100:3118`; still to see with the managed config once flakes-tnjz is done) Activate home in WSL, then do a real MCP OAuth from yolo (e.g. Cloudflare, flakes-pbel) via Windows → WSL → ssh pc → incus yolo, one click on the printed link. (Confirms WSL2 localhost forwarding of the 127.0.0.1-bound ssh -L, and that the ssh host alias used from WSL matches the Host patterns.)
- [ ] Direct Windows OpenSSH (unmanaged): add the same block to `%USERPROFILE%\.ssh\config` by hand:
  ```
  Host pc pc.* desktop desktop.* 172.22.1.9
    LocalForward 3118 10.100.0.100:3118
  ```

## Phase B — zero-click auto-open (deferred: one click on the OSC link is fine, per user 2026-10-22)
- [ ] WSL open-listener that runs `wslview <url>` (ensure `wslu` installed in the WSL home profile).
- [ ] WSL ssh `RemoteForward 10.100.0.1:OPEN localhost:OPEN` (bind host bridge IP) so container→`gateway:OPEN`→tunnel→WSL listener→`wslview`.
- [ ] Host sshd `GatewayPorts clientspecified` (the one non-flake host tweak) so the -R can bind the bridge IP.
- [ ] Attach wrapper detects `SSH_CONNECTION` and injects `BROWSER_ROUTE` accordingly; OSC (Phase A) stays the fallback.
