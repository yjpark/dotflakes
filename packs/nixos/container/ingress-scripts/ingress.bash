DOMAIN="$(hostname).incus"

# Collect listening ports (excluding system ports, Caddy admin, dnsmasq, the
# MCP OAuth bridge and the egress-proxy redirect — hidden on the hub page too)
LISTENING=$(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un \
  | awk '$1 > 1000' | grep -vE '^(2019|5354|5355|3118|12345)$' || true)

echo "Listening ports (each reachable as https://<port>.$DOMAIN):"
if [ -z "$LISTENING" ]; then
  echo "  (none)"
else
  while IFS= read -r PORT; do
    echo "  https://$PORT.$DOMAIN  ->  127.0.0.1:$PORT"
  done <<< "$LISTENING"
fi

echo ""
echo "From outside: https://$(hostname)-<port>.<host>.yjpark.org, all listed on https://hub.<host>.yjpark.org"
