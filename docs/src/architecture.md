# Architecture

## Autowiring Pattern

Most `default.nix` files contain a single line:

```nix
{flake, ...}: flake.inputs.autowire.wireImports ./.
```

This auto-discovers and composes all `.nix` files in the same directory into a merged NixOS/Home Manager module. Adding a new `.nix` file to an autowired directory automatically includes it — no manual imports needed.

## Layered Composition

Configuration is built up in layers:

1. **`flake.nix`** — Declares all inputs; outputs are generated via `nixos-unified`
2. **`modules/flake/`** — Flake-level glue (formatter, packages, apps). Each `.nix` file here is a `flake-parts` module auto-included by the framework
3. **`modules/{home,nixos}/`** — Reusable Home Manager / NixOS modules, autowired
4. **`mixins/{home,nixos}/`** — Platform-specific layers (linux, darwin) and host/container-specific config
5. **`configurations/{home,nixos}/`** — Per-host final configurations that compose modules + mixins

## Custom Options

`modules/home/options.nix` defines the `me` option set used throughout Home Manager modules:

- `me.username`
- `me.fullname`
- `me.email`

These are set in each host's configuration file (e.g., `configurations/home/yjpark.nix`).

## Overlays and Custom Packages

`overlays/default.nix` autowires from `./`, picking up `packages.nix` in the overlays directory. Custom packages are automatically available as nixpkgs overlays throughout the configuration.
