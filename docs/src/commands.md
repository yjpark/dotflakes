# Key Commands

Tasks are defined in `mise.toml`. Use `mise tasks` to list all available tasks.

## Daily Use

```bash
# Home Manager activation (applies user-level config)
mise run _activate-home

# Build NixOS config for current host (builds without switching by default)
mise run build-host

# Switch NixOS config (applies system-level config, requires sudo)
mise run _switch-host
```

## Flake Maintenance

```bash
# Update all flake inputs
mise run flake-update

# Update specific inputs
mise run flake-update nixpkgs home-manager

# Show flake outputs
mise run show

# Format Nix files (uses nixpkgs-fmt)
nix fmt
```

## Documentation

```bash
# Serve docs locally (hot-reload)
mise run docs-serve

# Build static docs site
mise run docs-build
```

## Nix Directly

```bash
# Activate Home Manager (same as mise run _activate-home)
nix run

# Build a specific package
nix build .#docs
```
