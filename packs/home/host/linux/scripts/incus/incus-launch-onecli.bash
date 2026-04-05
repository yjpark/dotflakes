#!/usr/bin/env bash

# Launch the OneCLI incus container.
# OneCLI runs at 10.100.0.2 with native NixOS postgresql + podman onecli image.
# After launch, run: sudo systemctl start onecli-init-ca-and-secrets
# (or it will run automatically on the next nixos-rebuild switch).

incus launch onecli onecli

# Required for podman to run inside the LXC container
incus config set onecli security.nesting true

# Static IP (referenced by incus-ingress.nix and onecli seeder)
incus config device override onecli eth0 ipv4.address=10.100.0.2
