{pkgs, ...}: let
  ingressSyncScript = pkgs.writeShellScriptBin "ingress-sync" ''
    exec systemctl restart ingress-sync.service
  '';

  ingressScript = pkgs.writeShellScriptBin "ingress" ''
    HOSTNAME=$(hostname)
    DOMAIN="$HOSTNAME.incus"
    CADDYFILE=/etc/caddy/Caddyfile

    # Collect listening ports (excluding Caddy itself)
    LISTENING=$(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un | grep -v '^80$' | grep -v '^443$')

    # Collect ports from Caddyfile
    CADDY_PORTS=""
    if [ -f "$CADDYFILE" ]; then
      CADDY_PORTS=$(grep -oP '^\d+(?=\.)' "$CADDYFILE" | sort -un)
    fi

    echo "Local listening ports:"
    if [ -z "$LISTENING" ]; then
      echo "  (none)"
    else
      for PORT in $LISTENING; do
        echo "  127.0.0.1:$PORT"
      done
    fi

    echo ""
    echo "Active ingress routes (from Caddy config):"
    if [ -z "$CADDY_PORTS" ]; then
      echo "  (none)"
    else
      for PORT in $CADDY_PORTS; do
        echo "  https://$PORT.$DOMAIN  →  127.0.0.1:$PORT"
      done
    fi

    # Warn on divergences
    WARNINGS=""
    for PORT in $LISTENING; do
      if ! echo "$CADDY_PORTS" | grep -qx "$PORT"; then
        WARNINGS="$WARNINGS\n  WARNING: port $PORT is listening but not in Caddy config (run ingress-sync?)"
      fi
    done
    for PORT in $CADDY_PORTS; do
      if ! echo "$LISTENING" | grep -qx "$PORT"; then
        WARNINGS="$WARNINGS\n  WARNING: port $PORT is in Caddy config but not currently listening"
      fi
    done
    if [ -n "$WARNINGS" ]; then
      echo ""
      echo "Divergences:"
      echo -e "$WARNINGS"
    fi
  '';

  caddyConfigScript = pkgs.writeShellScript "generate-caddyfile" ''
    HOSTNAME=$(hostname)
    DOMAIN="$HOSTNAME.incus"
    CADDYFILE=/etc/caddy/Caddyfile

    CONFIG=""
    for PORT in $(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un); do
      [ "$PORT" = "80" ] && continue
      [ "$PORT" = "443" ] && continue
      CONFIG="$CONFIG
    $PORT.$DOMAIN {
      tls internal
      reverse_proxy 127.0.0.1:$PORT
    }
    "
    done

    echo "$CONFIG" > "$CADDYFILE"
    systemctl reload caddy.service 2>/dev/null || systemctl restart caddy.service
  '';
in {
  services.caddy = {
    enable = true;
  };

  # Wildcard DNS for *.$(hostname).incus → 127.0.0.1 so wget/curl work inside the container
  services.dnsmasq = {
    enable = true;
    settings = {
      # Resolve *.incus to loopback; the pattern matches any subdomain of any .incus host
      address = [ "/.incus/127.0.0.1" ];
      # Don't forward .incus queries upstream
      local = [ "/.incus/" ];
    };
  };

  # Use local dnsmasq for DNS resolution inside the container
  networking.nameservers = [ "127.0.0.1" ];

  systemd.services.ingress-sync = {
    description = "Regenerate Caddy ingress config from listening ports";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = caddyConfigScript;
    };
    after = ["caddy.service"];
    requires = ["caddy.service"];
  };

  environment.systemPackages = [
    ingressScript
    ingressSyncScript
  ];
}
