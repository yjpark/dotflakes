#!/usr/bin/env bash

# Check OneCLI proxy configuration and verify injection is working.
# Tests against httpbin.org (matched by the default wildcard secret).

set -eu

source `which color-logging`

# Check /etc/onecli-proxy-auth file status
info "Checking /etc/onecli-proxy-auth ..."
if [[ -e /etc/onecli-proxy-auth ]]; then
  info "  file exists: $(ls -la /etc/onecli-proxy-auth)"
  if [[ -r /etc/onecli-proxy-auth ]]; then
    info "  file is readable by current user ($(whoami))"
  else
    error "  file is NOT readable by current user ($(whoami)) — run onecli-push-proxy-auth on the host to fix permissions"
    exit 1
  fi
else
  error "  file does not exist — run onecli-push-proxy-auth on the host"
  exit 1
fi

# Source proxy auth if HTTPS_PROXY is not already in the environment
if [[ -z "${HTTPS_PROXY:-}" ]]; then
  info "HTTPS_PROXY not set in environment, sourcing /etc/onecli-proxy-auth ..."
  # shellcheck source=/dev/null
  source /etc/onecli-proxy-auth
  if [[ -z "${HTTPS_PROXY:-}" ]]; then
    error "HTTPS_PROXY still not set after sourcing /etc/onecli-proxy-auth"
    exit 1
  fi
  info "  sourced successfully"
else
  info "HTTPS_PROXY already set in environment (from profile.d or manual export)"
fi

MASKED_PROXY=$(echo "$HTTPS_PROXY" | sed 's|:\([^:]*\)@|:***@|')
info "HTTPS_PROXY: $MASKED_PROXY"
info "HTTP_PROXY:  $(echo "${HTTP_PROXY:-<not set>}" | sed 's|:\([^:]*\)@|:***@|')"
info "NODE_EXTRA_CA_CERTS: ${NODE_EXTRA_CA_CERTS:-<not set>}"

# Verify CA cert exists
if [[ -n "${NODE_EXTRA_CA_CERTS:-}" ]]; then
  if [[ -r "$NODE_EXTRA_CA_CERTS" ]]; then
    info "  CA cert file exists and is readable"
  else
    warn "  CA cert file missing or not readable: $NODE_EXTRA_CA_CERTS"
  fi
fi

info "Testing injection via httpbin.org/headers ..."
if ! RESPONSE=$(curl -sf https://httpbin.org/headers); then
  error "curl to httpbin.org failed — check proxy connectivity and CA cert"
  info "Trying without proxy for comparison ..."
  curl -sf --noproxy '*' https://httpbin.org/headers | jq . || error "Direct connection also failed"
  exit 1
fi
echo "$RESPONSE" | jq .

INJECTED=$(echo "$RESPONSE" | jq -r '.headers | to_entries[] | select(.value | contains("ONECLI") or contains("WELCOME")) | "\(.key): \(.value)"')
if [[ -n "$INJECTED" ]]; then
  info "Injection confirmed: $INJECTED"
else
  warn "No OneCLI injection detected in response headers — check hostPattern and secrets"
fi
