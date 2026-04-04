#!/usr/bin/env bash

incus launch hermes hermes

incus config set hermes security.nesting true

# Static IP for ingress DNS (see mixins/nixos/host/incus-ingress.nix)
incus config device override hermes eth0 ipv4.address=10.100.0.103

incus config device add hermes hermes disk \
  source=/home/yjpark/bots/hermes \
  path=/home/yj/hermes \
  shift=true

incus config device add hermes agents disk \
  source=/home/yjpark/bots/agents \
  path=/home/yj/agents \
  shift=true

# Push OneCLI CA cert so the container trusts the credential proxy.
# Requires OneCLI to be running on the host (nixos-rebuild switch first).
# Re-run manually if OneCLI is restarted and its CA cert changes.
onecli-push-ca hermes
