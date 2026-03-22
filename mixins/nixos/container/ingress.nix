{pkgs, ...}: let
  ingressSyncScript = pkgs.writeShellScriptBin "ingress-sync" ''
    exec systemctl restart ingress-sync.service
  '';

  ingressScript = pkgs.writeShellScriptBin "ingress" ''
    HOSTNAME=$(hostname)
    DOMAIN="$HOSTNAME.incus"
    echo "Active ingress routes:"
    ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un | while read PORT; do
      [ "$PORT" = "80" ] && continue
      [ "$PORT" = "443" ] && continue
      echo "  https://$PORT.$DOMAIN  →  127.0.0.1:$PORT"
    done
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
