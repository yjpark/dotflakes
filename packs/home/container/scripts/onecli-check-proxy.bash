#!/usr/bin/env bash

# Check OneCLI proxy configuration and verify injection is working.
# Tests injection against the GitHub API (matched by the GH_TOKEN_EDGER_DEV secret).

set -eu

source `which color-logging`

# Check /etc/onecli-proxy-auth file status
info "Checking /etc/onecli-proxy-auth ..."
if [[ -e /etc/onecli-proxy-auth ]]; then
  info "  file exists: $(ls -la /etc/onecli-proxy-auth)"
  if [[ -r /etc/onecli-proxy-auth ]]; then
    info "  file is readable by current user ($(whoami))"
  else
    error "  file is NOT readable by current user ($(whoami)) — run onecli-push-proxy-auth on the host to fix"
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
# (pushed by onecli-push-ca, merged into the bundle by onecli-ca-bundle.service)
ONECLI_CA="/var/lib/onecli/ca.crt"
if [[ -r "$ONECLI_CA" ]]; then
  info "  OneCLI CA cert exists: $ONECLI_CA"
  ACTIVE_BUNDLE="${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}"
  CA_LINE=$(sed -n 2p "$ONECLI_CA")
  if [[ -r "$ACTIVE_BUNDLE" ]] && grep -qF -- "$CA_LINE" "$ACTIVE_BUNDLE" 2>/dev/null; then
    info "  OneCLI CA found in $ACTIVE_BUNDLE"
  else
    warn "  OneCLI CA NOT found in $ACTIVE_BUNDLE — run onecli-push-ca on the host"
  fi
else
  warn "  OneCLI CA cert missing or unreadable — run onecli-push-ca on the host"
fi

# Quick TLS verification: if HTTPS through the proxy fails but direct works,
# the OneCLI CA is missing from the CA bundle.
info "Verifying TLS through proxy ..."
if ! curl -sf https://github.com > /dev/null 2>&1; then
  if curl -sf --noproxy '*' https://github.com > /dev/null 2>&1; then
    error "TLS through proxy FAILED but direct HTTPS works — OneCLI CA is missing from CA bundle"
    error "Fix: run onecli-push-ca on the host to re-push the CA cert"
    exit 1
  else
    error "Both proxied and direct HTTPS failed — network issue (not CA related)"
    exit 1
  fi
fi
info "  TLS through proxy OK"

# OneCLI replaces existing headers — it does not add missing ones.
# Send a placeholder Authorization header so OneCLI can inject the real value:
# GitHub answers 200 only if the placeholder was replaced with a valid token.
URL="https://api.github.com/repos/edger-dev/jig"
info "Testing injection via $URL ..."
info "  (sending placeholder Authorization header for OneCLI to replace)"
STATUS=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: token PLACEHOLDER" "$URL")
case "$STATUS" in
  200) info "Injection confirmed — GitHub accepted the injected token" ;;
  401) warn "GitHub rejected the placeholder — OneCLI did not inject"
       warn "Check secrets are seeded and granted to the default agent (onecli-reseed on the host)" ;;
  *)   error "Unexpected HTTP $STATUS from $URL — check proxy connectivity"
       exit 1 ;;
esac
