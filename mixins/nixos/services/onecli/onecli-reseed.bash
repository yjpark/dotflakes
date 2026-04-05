#!/usr/bin/env bash

# Seed API secrets into OneCLI and push CA + proxy auth to agent containers.
# Run manually after launching OneCLI, or after a container reboot.
# Requires: sudo (to read /run/secrets/onecli-secrets)

set -eu

source `which color-logging`

SECRETS_FILE="/run/secrets/onecli-secrets"
BASE_URL="http://10.100.0.2:10254"

# Per-secret injection config (mirrors secretConfigs in default.nix).
# Keys must match names in the SOPS secrets file (onecli-secrets.txt).
# Secrets not listed here get the _default config.
SECRET_CONFIG=$(cat <<'EOF'
{
  "_default": {
    "hostPattern": "example.com",
    "headerName": "x-api-key"
  },
  "CONTEXT7_API_KEY": {
    "hostPattern": "context7.com",
    "headerName": "Authorization",
    "valueFormat": "Bearer {value}"
  },
  "GH_TOKEN_EDGER_DEV": {
    "hostPattern": "*.github.com",
    "pathPattern": "/repos/edger-dev/*",
    "headerName": "Authorization",
    "valueFormat": "token {value}"
  },
  "GH_TOKEN_YJPARK": {
    "hostPattern": "*.github.com",
    "pathPattern": "/repos/yjpark/*",
    "headerName": "Authorization",
    "valueFormat": "token {value}"
  },
  "GITHUB_TOKEN_EDGER_DEV": {
    "hostPattern": "github.com",
    "pathPattern": "/edger-dev/*",
    "headerName": "Authorization",
    "valueFormat": "Basic {value}",
    "encoding": "basic-auth"
  },
  "GITHUB_TOKEN_YJPARK": {
    "hostPattern": "github.com",
    "pathPattern": "/yjpark/*",
    "headerName": "Authorization",
    "valueFormat": "Basic {value}",
    "encoding": "basic-auth"
  },
  "GH_TOKEN_GRAPHQL": {
    "hostPattern": "api.github.com",
    "pathPattern": "/graphql",
    "headerName": "Authorization",
    "valueFormat": "token {value}"
  },
  "GITHUB_COPILOT_TOKEN": {
    "hostPattern": "api.githubcopilot.com",
    "headerName": "Authorization",
    "valueFormat": "Bearer {value}"
  }
}
EOF
)

AGENT_CONTAINERS=(yolo spacebot hermes)

# Wait for OneCLI to be ready
for i in $(seq 1 30); do
  if curl -sf "$BASE_URL/api/auth/session" > /dev/null 2>&1; then
    info "OneCLI is ready"
    break
  fi
  info "Waiting for OneCLI... ($i/30)"
  sleep 2
done

# Retrieve the admin API key
info "Fetching local admin API key..."
API_KEY=$(curl -sf "$BASE_URL/api/user/api-key" | jq -r '.apiKey')

if [[ -z "$API_KEY" || "$API_KEY" == "null" ]]; then
  error "Could not retrieve API key from OneCLI"
  exit 1
fi
info "Got API key: ${API_KEY:0:8}..."

info "Seeding secrets into OneCLI..."

while IFS='=' read -r key value; do
  [[ "$key" =~ ^# ]] && continue
  [[ -z "$key" ]] && continue
  [[ "$key" =~ _COMMENT$ ]] && continue

  secret_config=$(echo "$SECRET_CONFIG" | jq -r --arg k "$key" \
    'if .[$k] then .[$k] else ._default end')

  host_pattern=$(echo "$secret_config" | jq -r '.hostPattern')
  path_pattern=$(echo "$secret_config" | jq -r '.pathPattern // "*"')
  header_name=$(echo "$secret_config" | jq -r '.headerName')
  value_format=$(echo "$secret_config" | jq -r '.valueFormat // "{value}"')
  encoding=$(echo "$secret_config" | jq -r '.encoding // "none"')

  if [[ "$encoding" == "basic-auth" ]]; then
    value=$(printf 'x-access-token:%s' "$value" | base64 -w0)
  fi

  header_display="$header_name: ${value_format/\{value\}/***}"
  info "Seeding: $key (host=$host_pattern, path=$path_pattern, injects '$header_display')"

  existing_id=$(curl -sf "$BASE_URL/api/secrets" \
    -H "Authorization: Bearer $API_KEY" | \
    jq -r --arg name "$key" '.[] | select(.name == $name) | .id // empty')
  if [[ -n "$existing_id" ]]; then
    curl -sf -X DELETE "$BASE_URL/api/secrets/$existing_id" \
      -H "Authorization: Bearer $API_KEY" && info "Deleted existing: $key"
  fi

  curl -sf -X POST "$BASE_URL/api/secrets" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg name "$key" \
      --arg value "$value" \
      --arg hp "$host_pattern" \
      --arg pp "$path_pattern" \
      --arg hn "$header_name" \
      --arg vf "$value_format" \
      '{
        name: $name,
        type: "generic",
        value: $value,
        hostPattern: $hp,
        pathPattern: $pp,
        injectionConfig: { headerName: $hn, valueFormat: $vf }
      }')" && info "OK: $key" || warn "ERROR: Failed to seed $key"
done < "$SECRETS_FILE"

info "Done seeding. Verify secrets at $BASE_URL"

# Push authenticated proxy URL to agent containers
info "Fetching default agent token for proxy auth..."
AGENT_TOKEN=$(curl -sf "$BASE_URL/api/agents/default" | jq -r '.accessToken')
if [[ -z "$AGENT_TOKEN" || "$AGENT_TOKEN" == "null" ]]; then
  error "Could not retrieve agent token from /api/agents/default"
  exit 1
fi
info "Got agent token: ${AGENT_TOKEN:0:4}..."
PROXY_URL="http://x:${AGENT_TOKEN}@10.100.0.2:10255"

for container in "${AGENT_CONTAINERS[@]}"; do
  if incus list --format json | jq -e --arg n "$container" \
      '.[] | select(.name == $n) | select(.status == "Running")' > /dev/null 2>&1; then
    printf 'HTTPS_PROXY="%s"\nHTTP_PROXY="%s"\n' "$PROXY_URL" "$PROXY_URL" | \
      incus file push - "$container/etc/onecli-proxy-auth"
    incus exec "$container" -- chmod 644 /etc/onecli-proxy-auth
    info "Pushed proxy auth to $container"

    info "Pushing OneCLI CA to $container..."
    CA_PEM=$(curl -sf "$BASE_URL/api/gateway/ca")
    if [[ -z "$CA_PEM" ]]; then
      warn "Could not fetch OneCLI CA from $BASE_URL/api/gateway/ca"
      continue
    fi
    incus exec "$container" -- mkdir -p /var/lib/onecli
    echo "$CA_PEM" | incus file push - "$container/var/lib/onecli/ca.crt"
    info "Pushed CA to $container"
  else
    warn "Skipping $container (not running)"
  fi
done
