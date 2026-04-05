#!/usr/bin/env bash

# Push the OneCLI CA certificate into Incus containers.
# Written to /var/lib/onecli/ca.crt — the container's onecli-ca-bundle.path unit
# watches this path and rebuilds /var/lib/ingress/ca-bundle.crt automatically.
# Run once after launching a new container, or after OneCLI is reset/rotated.
# Usage: onecli-push-ca [container...]  (default: yolo)

set -eu

source `which color-logging`

if [[ $# -eq 0 ]]; then
  CONTAINERS=(yolo spacebot hermes)
else
  CONTAINERS=("$@")
fi
CA_PEM=$(curl -sf http://10.100.0.2:10254/api/gateway/ca)

for CONTAINER in "${CONTAINERS[@]}"; do
  info "Pushing OneCLI CA to $CONTAINER..."
  incus exec "$CONTAINER" -- mkdir -p /var/lib/onecli
  echo "$CA_PEM" | incus file push - "$CONTAINER/var/lib/onecli/ca.crt"
  info "Done: $CONTAINER (onecli-ca-bundle.service will rebuild the bundle)"
done
