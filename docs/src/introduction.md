# Introduction

This repository is a Nix Flakes-based dotfiles and system configuration, managing NixOS systems and Home Manager user environments across multiple machines.

It uses [`flake-parts`](https://github.com/hercules-ci/flake-parts) with [`autowire`](https://github.com/edger-dev/jig) (from `jig`) for automatic module discovery and composition.

## Repository Structure

```
flake.nix                    # Entry point, declares all inputs
  → flake/*.nix              # Flake-level glue (configs, formatter, activation)
  → packs/{home,nixos}/      # Autowired packs (common, host, container, gui)
  → mixins/{home,nixos}/     # Opt-in configs (manually imported by configurations)
  → home/*.nix               # Per-user base Home Manager configurations
  → nixos/{hosts,containers} # Per-host/container NixOS configurations
```

- **`packs/`** — Autowired collections — import a pack, get everything in it
- **`mixins/`** — Opt-in configuration pieces (services, hardware, versions)
- **`home/`** — Base Home Manager configs (`yjpark.nix`, `yj.nix`)
- **`nixos/`** — Per-host and per-container NixOS configs
- **`secrets/`** — SOPS-encrypted secrets (age keys, per-host)
- **`private/`** — Host-specific private configs (gitignored, present on deployed machines)
