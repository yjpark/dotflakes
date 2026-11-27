---
# flakes-0n76
title: Authenticate hub peers with per-peer Ed25519 keys
status: in-progress
type: feature
created_at: 2026-11-27T13:24:37Z
updated_at: 2026-11-27T13:24:37Z
---

Replace the shared hub token with per-peer Ed25519 identities and nonce-signed challenges. Generate one keypair per hub/node/container, publish only public keys in flakes, and keep private keys restricted to their own machines. During rollout accept token or signature, then require signatures and remove the shared token. Done when hub/node/kudo signed auth tests pass, public and private Home Manager/NixOS configurations build, live signed discovery and messaging pass, and token-only fallback can be disabled.
