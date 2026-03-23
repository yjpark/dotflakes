#!/usr/bin/env bash

# Check OneCLI proxy configuration and verify injection is working.
# Tests against httpbin.org (matched by the default wildcard secret).

set -eu

source `which color-logging`

# Source proxy auth if HTTPS_PROXY is not already in the environment
if [[ -z "${HTTPS_PROXY:-}" ]]; then
  if [[ -r /etc/onecli-proxy-auth ]]; then
    # shellcheck source=/dev/null
    source /etc/onecli-proxy-auth
  else
    error "/etc/onecli-proxy-auth not found — run onecli-push-proxy-auth on the host"
    exit 1
  fi
fi

MASKED_PROXY=$(echo "$HTTPS_PROXY" | sed 's|:\([^:]*\)@|:***@|')
info "HTTPS_PROXY: $MASKED_PROXY"
info "NODE_EXTRA_CA_CERTS: ${NODE_EXTRA_CA_CERTS:-<not set>}"

info "Testing injection via httpbin.org/headers..."
RESPONSE=$(curl -sf https://httpbin.org/headers)
echo "$RESPONSE" | jq .

INJECTED=$(echo "$RESPONSE" | jq -r '.headers | to_entries[] | select(.value | contains("ONECLI") or contains("WELCOME")) | "\(.key): \(.value)"')
if [[ -n "$INJECTED" ]]; then
  info "Injection confirmed: $INJECTED"
else
  warn "No OneCLI injection detected in response headers — check hostPattern and secrets"
fi
