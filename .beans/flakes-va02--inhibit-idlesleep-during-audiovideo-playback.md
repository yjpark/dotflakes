---
# flakes-va02
title: Inhibit idle/sleep during audio/video playback
status: completed
type: task
priority: normal
created_at: 2026-03-27T10:33:22Z
updated_at: 2026-03-28T05:20:15Z
order: zzy
---

Add sway-audio-idle-inhibit to prevent hypridle from powering off monitors when audio is playing (e.g. YouTube, Netflix in Chrome). Changes: add package to hypridle.nix and spawn at niri startup.

## Summary of Changes

- Added `sway-audio-idle-inhibit` package to `mixins/home/gui/linux/services/hypridle.nix`
- Added `spawn-at-startup "sway-audio-idle-inhibit"` to niri config (`config.common.kdl`)

The daemon monitors PipeWire/PulseAudio for active audio streams and sends a Wayland idle inhibit signal, preventing hypridle from powering off monitors during video/audio playback.
