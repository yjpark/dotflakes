# Flake Inputs

All inputs are declared in `flake.nix`. This page documents the purpose of each.

## Core / Framework

| Input | Purpose |
|-------|---------|
| `nixpkgs` | nixos-unstable — the primary package set |
| `home-manager` | User environment management |
| `flake-parts` | Flake composition framework |
| `nixos-unified` | Opinionated wrapper around flake-parts for NixOS + HM |
| `autowire` | Custom fork (`github:yjpark/autowire.nix`) — auto-discovers and composes `.nix` files in a directory |

## Software

| Input | Purpose |
|-------|---------|
| `sops-nix` | Declarative secret management with SOPS + age |
| `nixvim` | Neovim configured via Nix |
| `flox` | Developer environments |
| `nixidy` | Kubernetes GitOps (k8s manifest generation) |
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
