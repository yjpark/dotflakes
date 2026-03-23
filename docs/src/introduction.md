# Introduction

This repository is a Nix Flakes-based dotfiles and system configuration, managing NixOS systems and Home Manager user environments across multiple machines.

It uses the [`nixos-unified`](https://github.com/nix-community/nixos-unified) framework with [`autowire`](https://github.com/yjpark/autowire.nix) for automatic module discovery and composition.

## Repository Structure

```
flake.nix                          # Entry point, declares all inputs
  → modules/flake/toplevel.nix     # Flake-level glue (formatter, packages)
  → modules/{home,nixos}/          # Reusable modules (autowired)
  → mixins/{home,nixos}/           # Platform/version-specific configs
  → configurations/{home,nixos}/   # Per-host final configurations
```

- **`modules/`** — Core reusable NixOS/Home Manager modules
- **`mixins/`** — Platform-specific (linux/darwin) and version-specific configuration layers
- **`configurations/`** — Per-host configs that compose modules + mixins
- **`overlays/`** — Nixpkgs overlays and custom packages
- **`secrets/`** — SOPS-encrypted secrets (age keys, per-host)
- **`private/`** — Host-specific private configs (gitignored, present on deployed machines)
