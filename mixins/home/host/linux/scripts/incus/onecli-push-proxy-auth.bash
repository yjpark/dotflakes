#!/usr/bin/env bash

# Push the authenticated OneCLI proxy URL into Incus containers.
# Written to /etc/onecli-proxy-auth, sourced by /etc/profile.d/onecli-proxy.sh.
# Run automatically by onecli-seed-secrets after nixos-rebuild switch.
# Usage: onecli-push-proxy-auth [container...]  (default: yolo)

set -eu

source `which color-logging`

BASE_URL="http://10.100.0.1:10254"
CONTAINERS=("${@:-yolo}")

curl -sf "$BASE_URL/api/auth/session" > /dev/null
API_KEY=$(curl -sf "$BASE_URL/api/user/api-key" | jq -r '.apiKey')

if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
  error "Could not retrieve API key from OneCLI"
  exit 1
fi

PROXY_URL="http://x:${API_KEY}@10.100.0.1:10255"

for CONTAINER in "${CONTAINERS[@]}"; do
  if incus list --format json | jq -e --arg n "$CONTAINER" \
      '.[] | select(.name == $n) | select(.status == "Running")' > /dev/null 2>&1; then
    info "Pushing proxy auth to $CONTAINER..."
    printf 'HTTPS_PROXY="%s"\nHTTP_PROXY="%s"\n' "$PROXY_URL" "$PROXY_URL" | \
      incus file push - "$CONTAINER/etc/onecli-proxy-auth"
    info "Done: $CONTAINER"
  else
    warn "Skipping $CONTAINER (not running)"
  fi
done
