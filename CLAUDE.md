# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nix Flakes-based dotfiles and system configuration repository managing NixOS systems and Home Manager user environments across multiple machines. Uses the `nixos-unified` framework with `autowire` for automatic module discovery and composition.

## Key Commands

```bash
# Home Manager activation (applies user-level config)
just activate-home

# Build NixOS config for current host (dry run by default)
just build-host

# Switch NixOS config (applies system-level config, requires sudo)
just switch-host

# Update flake inputs (dependencies)
just update

# Show flake outputs
just show

# Format Nix files
nix fmt
```

The formatter is `nixpkgs-fmt` (configured in `modules/flake/toplevel.nix`).

## Architecture

### Autowiring Pattern

Most `default.nix` files contain a single line: `{flake, ...}: flake.inputs.autowire.default ./.` — this auto-discovers and composes all `.nix` files in the same directory into a merged NixOS/Home Manager module. Adding a new `.nix` file to an autowired directory automatically includes it.

### Layered Composition

```
flake.nix                          # Entry point, declares all inputs
  → modules/flake/toplevel.nix     # Flake-level glue (formatter, packages)
  → modules/{home,nixos}/          # Reusable modules (autowired)
  → mixins/{home,nixos}/           # Platform/version-specific configs
  → configurations/{home,nixos}/   # Per-host final configurations
```

- **modules/**: Core reusable modules, organized by `packages/`, `programs/`, `services/`, `settings/`, `scripts/`, `files/`
- **mixins/**: Platform-specific (linux/darwin) and version-specific (25.05, 24.11) configuration layers
- **configurations/**: Per-host configs that compose modules + mixins. Each host imports `self.homeModules.default` or `self.nixosConfigurations` plus version and platform mixins

### Custom Options

`modules/home/options.nix` defines the `me` option set (`me.username`, `me.fullname`, `me.email`) used throughout Home Manager modules. These are set in each host's configuration file (e.g., `configurations/home/yjpark.nix`).

### Overlays and Custom Packages

`overlays/default.nix` autowires from `./packages/`. Custom packages placed in the `packages/` directory are automatically available as overlays.

### Secrets

SOPS-nix with age encryption (`.sops.yaml`). Each host has its own age key. Encrypted files live in `secrets/` directories and files matching `secret.*`.

### Private Directory

`private/` (gitignored) contains host-specific private configs, encrypted secrets, and Kubernetes configurations. It is expected to exist on deployed machines.

## Flake Inputs

Primary: `nixpkgs` (nixos-unstable), `home-manager`, `flake-parts`, `nixos-unified`, `autowire` (custom fork at `github:yjpark/autowire.nix`)

Software: `sops-nix`, `nixvim`, `flox`, `nixidy` (k8s), `nixos-vscode-server`, `solaar` (Logitech), `llm-agents`

## Nix Conventions

- All configuration is declarative Nix — no imperative scripts
- Module files should follow existing patterns in their directory (look at sibling files)
- `nix run` activates Home Manager; `nixos-rebuild` handles system configs
- Host configs reference hostname via `` `hostname` `` (backtick subshell in justfile)
