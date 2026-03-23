#!/usr/bin/env bash

# List all secrets stored in OneCLI, showing config without exposing values.

set -eu

source `which color-logging`

BASE_URL="http://10.100.0.1:10254"

curl -sf "$BASE_URL/api/auth/session" > /dev/null
API_KEY=$(curl -sf "$BASE_URL/api/user/api-key" | jq -r '.apiKey')

if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
  log_error "Could not retrieve API key from OneCLI"
  exit 1
fi

info "Secrets in OneCLI ($BASE_URL):"
curl -sf "$BASE_URL/api/secrets" \
  -H "Authorization: Bearer $API_KEY" | \
  jq -r '.[] | "  \(.name)\n    host:   \(.hostPattern)\n    header: \(.injectionConfig.headerName): \(.injectionConfig.valueFormat // "{value}")"'
