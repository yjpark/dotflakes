# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nix Flakes-based dotfiles and system configuration repository managing NixOS systems and Home Manager user environments across multiple machines. Uses `flake-parts` with `autowire` (from `jig`) for automatic module discovery and composition.

## Key Commands

```bash
# Home Manager activation (applies user-level config)
mise run _activate-home

# Build NixOS config for current host (builds without switching by default)
mise run build-host

# Switch NixOS config (applies system-level config, requires sudo)
mise run _switch-host

# Update flake inputs (dependencies)
mise run flake-update

# Show flake outputs
mise run show

# Format Nix files
nix fmt
```

The formatter is `nixpkgs-fmt` (configured in `flake/toplevel.nix`).

Tasks are defined in `mise.toml`. Use `mise tasks` to list all available tasks.

## Architecture

### Autowiring Pattern

Pack roots use `wireImportsRecursively` to auto-discover all `.nix` files recursively. Subdirectories with a custom `default.nix` are treated as opaque (their default.nix is imported instead of recursing). The `autowire` binding comes from `jig.lib.autowire` (from `github:edger-dev/jig`).

### Layered Composition

```
flake.nix                    # Entry point, declares all inputs
  → flake/*.nix              # Flake-level glue (configs, formatter, activation)
  → packs/{home,nixos}/      # Autowired packs (common, host, container, gui)
  → mixins/{home,nixos}/     # Opt-in configs (manually imported by configurations)
  → home/*.nix               # Per-user base Home Manager configurations
  → nixos/{hosts,containers} # Per-host/container NixOS configurations
```

- **packs/**: Autowired collections — import a pack, get everything in it
- **mixins/**: Opt-in configuration pieces (services, hardware, versions)
- **home/**: Base Home Manager configs (`yjpark.nix`, `yj.nix`)
- **nixos/**: Per-host and per-container NixOS configs

### Home Manager Activation

Two user profiles exist:
- `yjpark`: used on physical hosts; base config (`home/yjpark.nix`) sets `stateVersion = "25.05"`
- `yj`: used in containers; base config (`home/yj.nix`) sets `stateVersion = "26.05"`

Host/container mixins live in `mixins/home/hosts/` and `mixins/home/containers/` — adding a `.nix` file there registers a new host/container automatically.

`flake/activate-home.nix`: The `mise run _activate-home` command matches the current hostname against known hosts (→ `yjpark@<host>`) then containers (→ `yj@<host>`), falling back to bare `<username>` for unknown hosts.

`flake/home-configs.nix`: Generates `username@host` entries for each host/container mixin plus a bare `username` fallback (without host suffix).

### Custom Options

`packs/home/common/options.nix` defines the `me` option set (`me.username`, `me.fullname`, `me.email`) used throughout Home Manager modules. These are set in each user's base config (e.g., `home/yjpark.nix`).

### Secrets

SOPS-nix with age encryption (`.sops.yaml`). Each host has its own age key. Encrypted files live in `secrets/` directories and files matching `secret.*`.

### Private Directory

`private/` (gitignored) contains host-specific private configs, encrypted secrets, and Kubernetes configurations. It is expected to exist on deployed machines.

## Flake Inputs

Primary: `nixpkgs` (nixos-unstable), `home-manager`, `flake-parts`, `jig` (`github:edger-dev/jig`, provides autowire lib)

Software: `sops-nix`, `nixvim`, `nixos-vscode-server`, `solaar` (Logitech), `llm-agents`

Desktop/UI: `claude-desktop`, `niri` (Wayland compositor), `xremap-flake`, `antigravity`, `jjui`

## Planning

Do NOT write design docs or plans to `docs/plans/`. All planning and design
work should be captured directly in beans (description + body). Beans are the
single source of truth for tracking work.

Do NOT start implementation during the planning stage. The outcome of planning
is beans with clear specs — enough detail for a clean design and implementation
stage later.

## Nix Conventions

- All configuration is declarative Nix — no imperative scripts
- Module files should follow existing patterns in their directory (look at sibling files)
- `nix run` activates Home Manager; `nixos-rebuild` handles system configs
- Host configs reference hostname via `$(hostname)` (shell subshell in mise tasks)
