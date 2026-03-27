---
# flakes-0u0f
title: Disable terminal bell sound
status: completed
type: task
priority: normal
created_at: 2026-03-27T10:54:56Z
updated_at: 2026-03-27T10:55:07Z
---

Disable audible bell in kitty and wezterm to prevent loud alert sounds during terminal work.

## Summary of Changes

- kitty: set `enable_audio_bell = no`
- wezterm: set `audible_bell = 'Disabled'`
