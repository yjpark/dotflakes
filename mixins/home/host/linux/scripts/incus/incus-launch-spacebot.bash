#!/usr/bin/env bash

incus launch spacebot spacebot

incus config set spacebot security.nesting true

# Static IP for ingress DNS (see mixins/nixos/host/incus-ingress.nix)
incus config device override spacebot eth0 ipv4.address=10.100.1.100

incus config device add spacebot spacebot disk \
  source=/home/yjpark/bots/spacebot \
  path=/var/lib/spacebot \
  shift=true

# Push OneCLI CA cert so the container trusts the credential proxy.
# Requires OneCLI to be running on the host (nixos-rebuild switch first).
# Re-run manually if OneCLI is restarted and its CA cert changes.
onecli-push-ca spacebot
