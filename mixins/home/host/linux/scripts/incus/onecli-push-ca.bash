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
  # Build a combined CA bundle (system CAs + OneCLI CA) so curl and other TLS tools
  # trust the MITM proxy without needing security.pki (which requires build-time access).
  info "  Building combined CA bundle..."
  incus exec "$CONTAINER" -- bash -c '
    SYSTEM_BUNDLE=$(readlink -f /etc/ssl/certs/ca-certificates.crt 2>/dev/null || readlink -f /etc/ssl/certs/ca-bundle.crt 2>/dev/null || echo "")
    if [ -n "$SYSTEM_BUNDLE" ] && [ -r "$SYSTEM_BUNDLE" ]; then
      cat "$SYSTEM_BUNDLE" /usr/local/share/ca-certificates/onecli-ca.crt > /etc/ssl/certs/ca-bundle-with-onecli.crt
    else
      cp /usr/local/share/ca-certificates/onecli-ca.crt /etc/ssl/certs/ca-bundle-with-onecli.crt
    fi
    chmod 644 /etc/ssl/certs/ca-bundle-with-onecli.crt
  '
  info "Done: $CONTAINER"
done
