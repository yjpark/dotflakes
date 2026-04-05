#!/usr/bin/env bash

# Push the authenticated OneCLI proxy URL into Incus containers.
# Written to /etc/onecli-proxy-auth, sourced by /etc/profile.d/onecli-proxy.sh.
# Run automatically by onecli-seed-secrets after nixos-rebuild switch.
# Usage: onecli-push-proxy-auth [container...]  (default: yolo)

set -eu

source `which color-logging`

BASE_URL="http://10.100.0.2:10254"
if [[ $# -eq 0 ]]; then
  CONTAINERS=(yolo spacebot hermes)
else
  CONTAINERS=("$@")
fi

info "Checking OneCLI session at $BASE_URL ..."
if ! curl -sf "$BASE_URL/api/auth/session" > /dev/null; then
  error "OneCLI session check failed at $BASE_URL/api/auth/session"
  exit 1
fi
info "OneCLI session OK"

info "Retrieving default agent token from $BASE_URL/api/agents/default ..."
AGENT_TOKEN=$(curl -sf "$BASE_URL/api/agents/default" | jq -r '.accessToken')

if [[ -z "$AGENT_TOKEN" || "$AGENT_TOKEN" == "null" ]]; then
  error "Could not retrieve agent token from OneCLI (got: ${AGENT_TOKEN:-<empty>})"
  exit 1
fi
info "Agent token retrieved (prefix: ${AGENT_TOKEN:0:4}..., ${#AGENT_TOKEN} chars)"

PROXY_URL="http://x:${AGENT_TOKEN}@10.100.0.2:10255"
MASKED_PROXY="http://x:***@10.100.0.2:10255"

for CONTAINER in "${CONTAINERS[@]}"; do
  if incus list --format json | jq -e --arg n "$CONTAINER" \
      '.[] | select(.name == $n) | select(.status == "Running")' > /dev/null 2>&1; then
    info "Pushing proxy auth to $CONTAINER ..."
    info "  proxy URL: $MASKED_PROXY"
    printf 'HTTPS_PROXY="%s"\nHTTP_PROXY="%s"\n' "$PROXY_URL" "$PROXY_URL" | \
      incus file push - "$CONTAINER/etc/onecli-proxy-auth"
    info "Setting /etc/onecli-proxy-auth readable for all users ..."
    incus exec "$CONTAINER" -- chmod 644 /etc/onecli-proxy-auth
    info "Verifying file permissions ..."
    incus exec "$CONTAINER" -- ls -la /etc/onecli-proxy-auth
    info "Done: $CONTAINER"
  else
    warn "Skipping $CONTAINER (not running)"
  fi
done
