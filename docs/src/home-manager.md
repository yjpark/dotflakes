# Home Manager

## User Profiles

Two user profiles exist in this configuration:

| Username | Used On | Base Config | State Version |
|----------|---------|-------------|---------------|
| `yjpark` | Physical hosts | `configurations/home/yjpark.nix` | `25.05` |
| `yj` | Containers | `configurations/home/yj.nix` | `26.05` |

## Host and Container Mixins

Host-specific configurations live in:
- **`mixins/home/hosts/`** — One `.nix` file per physical host
- **`mixins/home/containers/`** — One `.nix` file per container

Adding a `.nix` file to either directory automatically registers a new host or container via the autowire pattern — no manual imports needed.

## Activation Logic

`modules/flake/activate-home.nix` defines how `mise run _activate-home` resolves the correct Home Manager configuration:

1. Matches current hostname against known **hosts** → activates `yjpark@<host>`
2. Matches current hostname against known **containers** → activates `yj@<host>`
3. Falls back to `<username>@` for unknown hosts (the trailing `@` is required by nixos-unified for bare username fallback configs)

## Configuration Generation

`modules/flake/home-configs.nix` generates `username@host` entries for each host/container mixin, plus a bare `username` fallback (without host suffix). This populates `homeConfigurations` in the flake outputs.
