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
    error "  file is NOT readable by current user ($(whoami)) — run onecli-init-ca-and-secrets on the host to fix"
    exit 1
  fi
else
  error "  file does not exist — run onecli-init-ca-and-secrets on the host"
  exit 1
fi

# Source proxy auth if HTTPS_PROXY is not already in the environment
if [[ -z "${HTTPS_PROXY:-}" ]]; then
  info "HTTPS_PROXY not set in environment, sourcing /etc/onecli-proxy-auth ..."
  # shellcheck source=/dev/null
  source /etc/onecli-proxy-auth
  export HTTPS_PROXY HTTP_PROXY
  if [[ -z "${HTTPS_PROXY:-}" ]]; then
    error "HTTPS_PROXY still not set after sourcing /etc/onecli-proxy-auth"
    exit 1
  fi
  info "  sourced successfully"
else
  info "HTTPS_PROXY already set in environment (from profile.d or manual export)"
fi

# Show token prefix (e.g. aoc_ or oc_) to help debug auth issues
MASKED_PROXY=$(echo "$HTTPS_PROXY" | sed 's|:\([^:]\{4\}\)[^@]*@|:\1***@|')
info "HTTPS_PROXY: $MASKED_PROXY"
info "HTTP_PROXY:  $(echo "${HTTP_PROXY:-<not set>}" | sed 's|:\([^:]\{4\}\)[^@]*@|:\1***@|')"
info "NODE_EXTRA_CA_CERTS: ${NODE_EXTRA_CA_CERTS:-<not set>}"
info "SSL_CERT_FILE: ${SSL_CERT_FILE:-<not set>}"

# Verify OneCLI CA is present in the active CA bundle
ONECLI_CA="/usr/local/share/ca-certificates/onecli-ca.crt"
if [[ -r "$ONECLI_CA" ]]; then
  info "  OneCLI CA cert exists: $ONECLI_CA"
  # Check if it's been appended to the active bundle
  ACTIVE_BUNDLE="${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}"
  if [[ -r "$ACTIVE_BUNDLE" ]] && grep -q "# OneCLI CA" "$ACTIVE_BUNDLE" 2>/dev/null; then
    info "  OneCLI CA found in $ACTIVE_BUNDLE"
  else
    warn "  OneCLI CA NOT found in $ACTIVE_BUNDLE — run onecli-init-ca-and-secrets on the host"
  fi
else
  warn "  OneCLI CA cert missing — run onecli-init-ca-and-secrets on the host"
fi

# Quick TLS verification: if HTTPS through the proxy fails but direct works,
# the OneCLI CA is missing from the CA bundle.
info "Verifying TLS through proxy ..."
if ! curl -sf https://github.com > /dev/null 2>&1; then
  if curl -sf --noproxy '*' https://github.com > /dev/null 2>&1; then
    error "TLS through proxy FAILED but direct HTTPS works — OneCLI CA is missing from CA bundle"
    error "Fix: run onecli-init-ca-and-secrets on the host to re-push the CA cert"
    exit 1
  else
    error "Both proxied and direct HTTPS failed — network issue (not CA related)"
    exit 1
  fi
fi
info "  TLS through proxy OK"

# OneCLI replaces existing headers — it does not add missing ones.
# Send a placeholder Authorization header so OneCLI can inject the real value.
info "Testing injection via httpbin.org/anything ..."
info "  (sending placeholder Authorization header for OneCLI to replace)"
if ! RESPONSE=$(curl -sf -H "Authorization: Bearer PLACEHOLDER" https://httpbin.org/anything); then
  error "curl to httpbin.org failed — check proxy connectivity and CA cert"
  info "Trying without proxy for comparison ..."
  curl -sf --noproxy '*' https://httpbin.org/anything | jq . || error "Direct connection also failed"
  exit 1
fi
echo "$RESPONSE" | jq '.headers'

AUTH_HEADER=$(echo "$RESPONSE" | jq -r '.headers.Authorization // .headers.authorization // empty')
if [[ -n "$AUTH_HEADER" && "$AUTH_HEADER" != "Bearer PLACEHOLDER" ]]; then
  info "Injection confirmed — Authorization header was replaced by OneCLI"
elif [[ "$AUTH_HEADER" == "Bearer PLACEHOLDER" ]]; then
  warn "Authorization header still has placeholder value — OneCLI did not inject"
  warn "Check hostPattern matches httpbin.org and secrets are seeded"
else
  warn "No Authorization header in response — check proxy and OneCLI config"
fi
