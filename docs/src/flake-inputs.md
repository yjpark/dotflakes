# Flake Inputs

All inputs are declared in `flake.nix`. This page documents the purpose of each.

## Core / Framework

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable — the primary package set |
| `home-manager` | User environment management |
| `flake-parts` | Flake composition framework |
| `jig` | `github:edger-dev/jig` — provides autowire lib for auto-discovering and composing `.nix` files |

## Software

| Input | Purpose |
|-------|---------|
| `sops-nix` | Declarative secret management with SOPS + age |
| `nixvim` | Neovim configured via Nix |
| `nixos-vscode-server` | VS Code remote server support on NixOS |
| `solaar` | Logitech device manager |
| `llm-agents` | LLM agent tools |

## Desktop / UI

| Input | Purpose |
|-------|---------|
| `claude-desktop` | Claude desktop application |
| `niri` | Wayland compositor |
| `xremap-flake` | Key remapper for Wayland/X11 |
| `antigravity` | (UI tool) |
| `jjui` | TUI for the `jj` (Jujutsu) VCS |
