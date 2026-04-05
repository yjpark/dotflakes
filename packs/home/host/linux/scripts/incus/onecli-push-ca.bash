#!/usr/bin/env bash

# Push the OneCLI CA certificate into Incus containers so they trust the MITM proxy.
# Run once after launching a new container, or after OneCLI is reset.
# Usage: onecli-push-ca [container...]  (default: yolo)

set -eu

source `which color-logging`

CONTAINERS=("${@:-yolo}")
CA_PEM=$(curl -sf http://10.100.0.2:10254/api/gateway/ca)

for CONTAINER in "${CONTAINERS[@]}"; do
  info "Pushing OneCLI CA to $CONTAINER..."
  incus exec "$CONTAINER" -- mkdir -p /usr/local/share/ca-certificates
  echo "$CA_PEM" | incus file push - "$CONTAINER/usr/local/share/ca-certificates/onecli-ca.crt"
  # Append OneCLI CA to all CA bundles found in the container.
  # On NixOS, bundles are often Nix store symlinks (read-only), so we replace
  # the symlink with a mutable copy before appending.
  info "  Appending OneCLI CA to CA bundles..."
  incus exec "$CONTAINER" -- bash -c '
    ONECLI_CA=/usr/local/share/ca-certificates/onecli-ca.crt
    BUNDLES=(/etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-bundle.crt /var/lib/ingress/ca-bundle.crt)
    FOUND=0
    for bundle in "${BUNDLES[@]}"; do
      [ -e "$bundle" ] || continue
      FOUND=1
      # If it is a symlink (e.g. to Nix store), replace with a mutable copy
      if [ -L "$bundle" ]; then
        target=$(readlink -f "$bundle")
        rm "$bundle"
        cp "$target" "$bundle"
        chmod 644 "$bundle"
        echo "  Replaced symlink with mutable copy: $bundle"
      fi
      # Check if OneCLI CA is already appended
      if grep -q "# OneCLI CA" "$bundle" 2>/dev/null; then
        echo "  OneCLI CA already in $bundle"
      else
        printf "\n# OneCLI CA\n" >> "$bundle"
        cat "$ONECLI_CA" >> "$bundle"
        echo "  Appended OneCLI CA to $bundle"
      fi
    done
    if [ "$FOUND" -eq 0 ]; then
      echo "  WARNING: No CA bundle found in container"
    fi
  '
  info "Done: $CONTAINER"
done
