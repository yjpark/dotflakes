#!/usr/bin/env bash

# Push the OneCLI CA certificate into Incus containers so they trust the MITM proxy.
# Run once after launching a new container, or after OneCLI is reset.
# Usage: onecli-push-ca [container...]  (default: yolo)

set -eu

source `which color-logging`

CONTAINERS=("${@:-yolo}")
CA_PEM=$(curl -sf http://10.100.0.1:10254/api/gateway/ca)

for CONTAINER in "${CONTAINERS[@]}"; do
  info "Pushing OneCLI CA to $CONTAINER..."
  incus exec "$CONTAINER" -- mkdir -p /usr/local/share/ca-certificates
  echo "$CA_PEM" | incus file push - "$CONTAINER/usr/local/share/ca-certificates/onecli-ca.crt"
  # NixOS: CA trust is configured via security.pki.certificateFiles in onecli-proxy.nix.
  # Non-NixOS: run update-ca-certificates if available.
  if incus exec "$CONTAINER" -- which update-ca-certificates > /dev/null 2>&1; then
    incus exec "$CONTAINER" -- update-ca-certificates
  else
    info "  (no update-ca-certificates — NixOS uses security.pki.certificateFiles instead)"
  fi
  info "Done: $CONTAINER"
done
