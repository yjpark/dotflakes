#!/usr/bin/env bash
set -euo pipefail

hostname=kudo_pc.yjpark.org
tunnel=829deb72-9870-4b61-9120-bf748d85fbd2
secret=mixins/nixos/services/secrets/cloudflare-caddy.txt

eval "$(sops -d --output-type dotenv "$secret")"

zone_id=$(curl -fsS \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones?name=yjpark.org" |
  jq -r '.result[0].id')
content="$tunnel.cfargotunnel.com"
record_id=$(curl -fsS \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=CNAME&name=$hostname" |
  jq -r '.result[0].id // empty')
payload=$(jq -n \
  --arg name "$hostname" \
  --arg content "$content" \
  '{type:"CNAME",name:$name,content:$content,proxied:true,ttl:1}')

if [ -n "$record_id" ]; then
  method=PUT
  endpoint="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id"
else
  method=POST
  endpoint="https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records"
fi
curl -fsS -X "$method" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
  -H 'Content-Type: application/json' \
  --data "$payload" \
  "$endpoint" |
  jq -e '.success == true' >/dev/null
printf 'Cloudflare DNS: %s -> %s (proxied)\n' "$hostname" "$content"
