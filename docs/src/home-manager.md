# Home Manager

## User Profiles

Two user profiles exist in this configuration:

| Username | Used On | Base Config | State Version |
|----------|---------|-------------|---------------|
| `yjpark` | Physical hosts | `home/yjpark.nix` | `25.05` |
| `yj` | Containers | `home/yj.nix` | `26.05` |

## Host and Container Mixins

Host-specific configurations live in:
- **`mixins/home/hosts/`** — One `.nix` file per physical host
- **`mixins/home/containers/`** — One `.nix` file per container

Adding a `.nix` file to either directory automatically registers a new host or container — no manual imports needed.

## Activation Logic

`flake/activate-home.nix` defines how `mise run _activate-home` resolves the correct Home Manager configuration:

1. Matches current hostname against known **hosts** → activates `yjpark@<host>`
2. Matches current hostname against known **containers** → activates `yj@<host>`
3. Falls back to bare `<username>` for unknown hosts

## Configuration Generation

`flake/home-configs.nix` generates `username@host` entries for each host/container mixin, plus a bare `username` fallback (without host suffix). This populates `homeConfigurations` in the flake outputs.
