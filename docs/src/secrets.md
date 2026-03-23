# Secrets

Secrets are managed with [SOPS-nix](https://github.com/Mic92/sops-nix) using [age](https://age-encryption.org/) encryption.

## Setup

- Each host has its own age key
- Encrypted secret files live in `secrets/` directories and any files matching `secret.*`
- The `.sops.yaml` file at the repo root defines which age keys can decrypt which secrets

## Usage

Encrypted files are automatically decrypted at activation time by sops-nix and made available to NixOS/Home Manager modules as paths under `/run/secrets/`.

Refer to the [sops-nix documentation](https://github.com/Mic92/sops-nix) for creating and editing secrets.
