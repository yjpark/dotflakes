DOMAIN="$(hostname).incus"
DYNAMIC_CONF="/var/lib/caddy/ingress.conf"
HUB_CONF="/var/lib/caddy/hub.conf"
HUB_DIR="/var/lib/ingress/hub"

mkdir -p "$HUB_DIR"

CONFIG=""
HUB_ROUTES=""
SERVICES="[]"

while IFS=$'\t' read -r PORT PID PNAME; do
  [[ -z "$PORT" ]] && continue

  # Get working directory from /proc
  CWD=""
  if [[ -n "$PID" && -d "/proc/$PID" ]]; then
    CWD=$(readlink -f "/proc/$PID/cwd" 2>/dev/null || true)
    # Shorten: strip /home/<user>/ prefix
    CWD=${CWD#/home/*/}
  fi

  URL="http://${PORT}.${DOMAIN}"

  # Same-origin proxy route for hub iframe
  HUB_ROUTES+="
    handle_path /s/${PORT}/* {
      reverse_proxy localhost:${PORT} {
        header_down -X-Frame-Options
        header_down -Content-Security-Policy
        header_down -Content-Security-Policy-Report-Only
      }
    }
  "

  CONFIG+="
  ${PORT}.${DOMAIN} {
    tls internal
    reverse_proxy localhost:${PORT} {
      header_down -X-Frame-Options
      header_down -Content-Security-Policy
      header_down -Content-Security-Policy-Report-Only
    }
  }
  http://${PORT}.${DOMAIN} {
    reverse_proxy localhost:${PORT} {
      header_down -X-Frame-Options
      header_down -Content-Security-Policy
      header_down -Content-Security-Policy-Report-Only
    }
  }
  "

  SERVICES=$(echo "$SERVICES" | jq \
    --argjson port "$PORT" \
    --arg process "$PNAME" \
    --arg cwd "$CWD" \
    --arg url "$URL" \
    '. + [{port: $port, process: $process, cwd: $cwd, url: $url}]')
done < <(ss -tlnp | awk 'NR>1 {
  n = split($4, a, ":");
  port = a[n];
  if (port+0 <= 1000 || port+0 == 2019 || port+0 == 5354 || port+0 == 5355 || port+0 == 9999) next;
  pid = ""; pname = "";
  if (match($0, /pid=([0-9]+)/, m)) pid = m[1];
  if (match($0, /"([^"]+)"/, m)) pname = m[1];
  print port "\t" pid "\t" pname;
}' | sort -t$'\t' -k1,1 -un)

echo "$CONFIG" > "$DYNAMIC_CONF"
chmod 644 "$DYNAMIC_CONF"

# Write services.json for hub page
echo "$SERVICES" > "$HUB_DIR/services.json"
chmod 644 "$HUB_DIR/services.json"

# Generate hub Caddy config
cat > "$HUB_CONF" <<HUBEOF
  hub.$DOMAIN {
    tls internal
  $HUB_ROUTES
    handle /api/* {
      reverse_proxy localhost:9999
    }
    handle {
      root * $HUB_DIR
      file_server
    }
  }
  http://hub.$DOMAIN {
  $HUB_ROUTES
    handle /api/* {
      reverse_proxy localhost:9999
    }
    handle {
      root * $HUB_DIR
      file_server
    }
  }
HUBEOF
chmod 644 "$HUB_CONF"

systemctl reload caddy.service 2>/dev/null || systemctl restart caddy.service

# Update combined CA bundle so wget/curl trust Caddy's internal CA
CADDY_CA="/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
COMBINED="/var/lib/ingress/ca-bundle.crt"
if [ -f "$CADDY_CA" ]; then
  cat "$SYSTEM_CA" "$CADDY_CA" > "$COMBINED"
fi
