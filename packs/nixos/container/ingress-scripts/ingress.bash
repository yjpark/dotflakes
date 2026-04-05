DOMAIN="$(hostname).incus"
DYNAMIC_CONF="/var/lib/caddy/ingress.conf"

# Collect listening ports (excluding system/caddy ports)
# Ports <=1000 are filtered by awk; only exclude 2019 (Caddy admin API) above that threshold
LISTENING=$(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un \
  | awk '$1 > 1000' | grep -vE '^(2019|5354|5355|9999)$' || true)

# Collect ports from dynamic config
CADDY_PORTS=""
if [ -f "$DYNAMIC_CONF" ]; then
  CADDY_PORTS=$(grep -oP '\d+(?=\.\S+\.incus)' "$DYNAMIC_CONF" | sort -un || true)
fi

echo "Local listening ports:"
if [ -z "$LISTENING" ]; then
  echo "  (none)"
else
  while IFS= read -r PORT; do
    echo "  127.0.0.1:$PORT"
  done <<< "$LISTENING"
fi

echo ""
echo "Active ingress routes (from Caddy config):"
if [ -z "$CADDY_PORTS" ]; then
  echo "  (none)"
else
  while IFS= read -r PORT; do
    echo "  https://$PORT.$DOMAIN  ->  127.0.0.1:$PORT"
  done <<< "$CADDY_PORTS"
fi

echo ""
echo "Hub: http://hub.$DOMAIN"

# Warn on divergences
WARNINGS=""
while IFS= read -r PORT; do
  [ -z "$PORT" ] && continue
  if ! grep -qx "$PORT" <<< "$CADDY_PORTS" 2>/dev/null; then
    WARNINGS+="  WARNING: port $PORT is listening but not in Caddy config (run ingress-sync?)\n"
  fi
done <<< "$LISTENING"
while IFS= read -r PORT; do
  [ -z "$PORT" ] && continue
  if ! grep -qx "$PORT" <<< "$LISTENING" 2>/dev/null; then
    WARNINGS+="  WARNING: port $PORT is in Caddy config but not currently listening\n"
  fi
done <<< "$CADDY_PORTS"

if [ -n "$WARNINGS" ]; then
  echo ""
  echo "Divergences:"
  echo -e "$WARNINGS"
fi
