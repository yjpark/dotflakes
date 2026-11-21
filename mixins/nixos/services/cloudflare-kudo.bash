#!/usr/bin/env bash
set -euo pipefail

host="$(hostname)"
hostname="kudo_${host}.yjpark.org"
case "$host" in
pc)
  tunnel=829deb72-9870-4b61-9120-bf748d85fbd2
  ;;
edger)
  tunnel=f62c3a91-d7b5-48c3-921d-f22e0f0cd0e9
  ;;
*)
  printf 'No kudo Cloudflare tunnel is configured for host %s\n' "$host" >&2
  exit 1
  ;;
esac

# Requires Zone DNS:Edit, Account Access: Apps and Policies:Edit, and Account
# Cloudflare Tunnel:Edit. Reuses the same email policies as kudo_pc.
secret=mixins/nixos/services/secrets/cloudflare-caddy.txt
curl_opts=(-sS --connect-timeout 10 --max-time 30 --retry 2)
api_root=https://api.cloudflare.com/client/v4

CLOUDFLARE_API_TOKEN="$(sops -d "$secret")"
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN#CLOUDFLARE_API_TOKEN=}"

cf_api() {
  local method=$1
  local path=$2
  local payload=${3:-}
  local request=(curl "${curl_opts[@]}" -X "$method" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")
  if [ -n "$payload" ]; then
    request+=(-H 'Content-Type: application/json' --data "$payload")
  fi
  "${request[@]}" "$api_root$path" |
    jq -e --arg method "$method" --arg path "$path" '
      if .success == true then .
      else error("\($method) \($path): errors=\((.errors // []) | tojson) messages=\((.messages // []) | tojson)")
      end
    '
}

zone=$(cf_api GET '/zones?name=yjpark.org')
zone_id=$(jq -r '.result[0].id // empty' <<<"$zone")
account_id=$(jq -r '.result[0].account.id // empty' <<<"$zone")
if [ -z "$zone_id" ] || [ -z "$account_id" ]; then
  printf 'Could not find the yjpark.org Cloudflare zone\n' >&2
  exit 1
fi

app_payload=$(jq -n --arg hostname "$hostname" '{
  type: "self_hosted",
  name: $hostname,
  domain: $hostname,
  destinations: [{type: "public", uri: $hostname}],
  self_hosted_domains: [$hostname],
  app_launcher_visible: true,
  allowed_idps: [],
  auto_redirect_to_identity: false,
  skip_interstitial: true,
  session_duration: "24h",
  enable_binding_cookie: false,
  http_only_cookie_attribute: false,
  options_preflight_bypass: false,
  eager_redirect_cookie_setting: true,
  policies: [
    {id: "eaf0b47a-451e-4240-942e-2c460b8009e0", precedence: 1},
    {id: "94cd9ead-547b-4223-af6b-49cbcfcbca92", precedence: 2}
  ]
}')
apps=$(cf_api GET "/accounts/$account_id/access/apps?per_page=100")
current_app=$(jq -c --arg hostname "$hostname" \
  '([.result[] | select(.domain == $hostname)][0] // empty)' <<<"$apps")

if [ -z "$current_app" ]; then
  cf_api POST "/accounts/$account_id/access/apps" "$app_payload" >/dev/null
  printf 'Cloudflare Access: created %s\n' "$hostname"
elif ! jq -e -n --argjson current "$current_app" --argjson desired "$app_payload" '
  def settings: {
    name,
    domain,
    destinations,
    self_hosted_domains,
    app_launcher_visible,
    allowed_idps,
    auto_redirect_to_identity,
    skip_interstitial,
    session_duration,
    enable_binding_cookie,
    http_only_cookie_attribute,
    options_preflight_bypass,
    eager_redirect_cookie_setting,
    policies: [(.policies // [])[] | {id, precedence}]
  };
  ($current | settings) == ($desired | settings)
' >/dev/null; then
  app_id=$(jq -r '.id' <<<"$current_app")
  cf_api PUT "/accounts/$account_id/access/apps/$app_id" "$app_payload" >/dev/null
  printf 'Cloudflare Access: updated %s\n' "$hostname"
else
  printf 'Cloudflare Access: unchanged %s\n' "$hostname"
fi

content="$tunnel.cfargotunnel.com"
dns_records=$(cf_api GET "/zones/$zone_id/dns_records?type=CNAME&name=$hostname")
current_record=$(jq -c '.result[0] // empty' <<<"$dns_records")
payload=$(jq -n \
  --arg name "$hostname" \
  --arg content "$content" \
  '{type:"CNAME",name:$name,content:$content,proxied:true,ttl:1}')

if [ -n "$current_record" ] && jq -e -n \
  --argjson current "$current_record" \
  --argjson desired "$payload" \
  '($current | {type, name, content, proxied, ttl}) == $desired' >/dev/null; then
  printf 'Cloudflare DNS: unchanged %s -> %s (proxied)\n' "$hostname" "$content"
else
  if [ -n "$current_record" ]; then
    method=PUT
    record_id=$(jq -r '.id' <<<"$current_record")
    endpoint="/zones/$zone_id/dns_records/$record_id"
  else
    method=POST
    endpoint="/zones/$zone_id/dns_records"
  fi
  cf_api "$method" "$endpoint" "$payload" >/dev/null
  printf 'Cloudflare DNS: updated %s -> %s (proxied)\n' "$hostname" "$content"
fi

tunnel_path="/accounts/$account_id/cfd_tunnel/$tunnel/configurations"
current_tunnel=$(cf_api GET "$tunnel_path")
desired_config=$(jq -c --arg hostname "$hostname" '
  def catch_all: .hostname == null and .service == "http_status:404";
  (.result.config.ingress // []) as $original
  | ($original | map(select(.hostname != $hostname))) as $ingress
  | ($ingress | to_entries | map(select(.value | catch_all)) | .[0].key) as $index
  | if $index == null then
      error("Cloudflare tunnel has no 404 catch-all")
    else
      .result.config
      | .ingress = ($ingress[:$index] + [{
          hostname: $hostname,
          service: "http://10.100.0.100:80",
          originRequest: {httpHostHeader: "8080.yolo.incus"}
        }] + $ingress[$index:])
    end
' <<<"$current_tunnel")

if jq -e --argjson desired "$desired_config" \
  '.result.config == $desired' >/dev/null <<<"$current_tunnel"; then
  printf 'Cloudflare tunnel: unchanged %s\n' "$hostname"
else
  tunnel_payload=$(jq -n --argjson config "$desired_config" '{config: $config}')
  cf_api PUT "$tunnel_path" "$tunnel_payload" >/dev/null
  printf 'Cloudflare tunnel: updated %s\n' "$hostname"
fi
