#!/usr/bin/env bash

incus launch yolo yolo

incus config set yolo security.nesting true

# Static IP for ingress DNS (see mixins/nixos/host/incus-ingress.nix)
incus config device override yolo eth0 ipv4.address=10.100.0.100

incus config device add yolo agents disk \
  source=/home/yjpark/agents \
  path=/home/yj/agents \
  shift=true

# Push OneCLI CA cert so the container trusts the credential proxy.
# Requires OneCLI to be running on the host (nixos-rebuild switch first).
# Re-run manually if OneCLI is restarted and its CA cert changes.
onecli-push-ca yolo
