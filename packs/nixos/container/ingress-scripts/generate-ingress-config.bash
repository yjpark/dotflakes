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

# MCP OAuth callback bridge (see mcp-oauth-bridge.nix / bean flakes-wq6s).
# Claude Code's MCP OAuth callback listener binds 127.0.0.1:<port> only, but the
# callback arrives from a host-side forwarder on the container's eth0 IP. A
# socket bound to lo won't serve a connection arriving on eth0, so bridge
# <container-ip>:<port> -> 127.0.0.1:<port>. Bind the container IP only (not
# 0.0.0.0) so CC's own 127.0.0.1:<port> listener is left free — CC's env port
# has no availability check, so a 0.0.0.0 listener here would steal it.
MCP_PORT="${MCP_OAUTH_CALLBACK_PORT:-3118}"
MCP_CONF="/var/lib/caddy/mcp-oauth.conf"
# `|| true`: this script runs under `set -euo pipefail` (writeShellApplication),
# so a failing pipeline in the assignment (e.g. no default route during early
# boot) would otherwise abort the whole generator before the caddy reload.
CONTAINER_IP=$(ip -4 route get 1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src"){print $(i+1); exit}}') || true
if [[ -n "$CONTAINER_IP" ]]; then
  cat > "$MCP_CONF" <<MCPEOF
  http://:${MCP_PORT} {
    bind ${CONTAINER_IP}
    reverse_proxy 127.0.0.1:${MCP_PORT}
  }
MCPEOF
  chmod 644 "$MCP_CONF"
fi

systemctl reload caddy.service 2>/dev/null || systemctl restart caddy.service

# Update combined CA bundle so wget/curl trust Caddy's internal CA
CADDY_CA="/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
COMBINED="/var/lib/ingress/ca-bundle.crt"
if [ -f "$CADDY_CA" ]; then
  cat "$SYSTEM_CA" "$CADDY_CA" > "$COMBINED"
fi
