# Architecture

## Autowiring Pattern

Pack roots use `wireImportsRecursively` to auto-discover all `.nix` files recursively:

```nix
{flake, ...}: flake.inputs.autowire.wireImportsRecursively ./.
```

Subdirectories with a custom `default.nix` are treated as opaque — their `default.nix` is imported instead of recursing further. Adding a new `.nix` file to a pack directory automatically includes it.

## Layered Composition

Configuration is built up in layers:

1. **`flake.nix`** — Declares all inputs; outputs generated via `flake-parts`
2. **`flake/*.nix`** — Flake-level glue (configs, formatter, activation). Each `.nix` file is a `flake-parts` module imported by `flake.nix`
3. **`packs/{home,nixos}/`** — Autowired packs (common, host, container, gui). Import a pack, get everything in it
4. **`mixins/{home,nixos}/`** — Opt-in configuration pieces (services, hardware, versions), manually imported by host configs
5. **`home/*.nix`** — Per-user base Home Manager configurations
6. **`nixos/{hosts,containers}/`** — Per-host and per-container NixOS configurations

## Custom Options

`packs/home/common/options.nix` defines the `me` option set used throughout Home Manager modules:

- `me.username`
- `me.fullname`
- `me.email`

These are set in each user's base config (e.g., `home/yjpark.nix`).
