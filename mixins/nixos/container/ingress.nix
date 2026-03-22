{
  pkgs,
  lib,
  ...
}: let
  # System ports to exclude from ingress (Caddy itself, DNS, mDNS/LLMNR)
  excludedPorts = ["80" "443" "2019" "53" "5354" "5355"];
  excludeFilter = lib.concatMapStrings (p: " | grep -v '^${p}$'") excludedPorts;

  # Dynamic config lives here; Caddy imports it at reload time
  dynamicConf = "/var/lib/caddy/ingress.conf";

  caddyConfigScript = pkgs.writeShellApplication {
    name = "generate-ingress-config";
    runtimeInputs = with pkgs; [iproute2 gawk hostname systemd];
    text = ''
      DOMAIN="$(hostname).incus"

      CONFIG=""
      while IFS= read -r PORT; do
        CONFIG+="
      ''${PORT}.''${DOMAIN} {
        tls internal
        reverse_proxy 127.0.0.1:''${PORT}
      }
      "
      done < <(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un${excludeFilter})

      echo "$CONFIG" > "${dynamicConf}"
      systemctl reload caddy.service 2>/dev/null || systemctl restart caddy.service

      # Update combined CA bundle so wget/curl trust Caddy's internal CA
      CADDY_CA="/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
      SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
      COMBINED="/var/lib/ingress/ca-bundle.crt"
      if [ -f "$CADDY_CA" ]; then
        cat "$SYSTEM_CA" "$CADDY_CA" > "$COMBINED"
      fi
    '';
  };

  ingressSyncScript = pkgs.writeShellApplication {
    name = "ingress-sync";
    runtimeInputs = with pkgs; [systemd];
    text = ''
      exec /run/wrappers/bin/sudo systemctl restart ingress-sync.service
    '';
  };

  ingressScript = pkgs.writeShellApplication {
    name = "ingress";
    runtimeInputs = with pkgs; [iproute2 gawk hostname gnugrep];
    text = ''
      DOMAIN="$(hostname).incus"

      # Collect listening ports (excluding system/caddy ports)
      LISTENING=$(ss -tlnp | awk 'NR>1 {print $4}' | grep -oP '\d+$' | sort -un${excludeFilter})

      # Collect ports from dynamic config
      CADDY_PORTS=""
      if [ -f "${dynamicConf}" ]; then
        CADDY_PORTS=$(grep -oP '^\d+(?=\.)' "${dynamicConf}" | sort -un || true)
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
          echo "  https://$PORT.$DOMAIN  →  127.0.0.1:$PORT"
        done <<< "$CADDY_PORTS"
      fi

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
    '';
  };
in {
  # Static Caddyfile that imports our dynamically-generated config
  services.caddy = {
    enable = true;
    configFile = pkgs.writeText "Caddyfile" ''
      {
        log {
          level ERROR
        }
      }
      import /var/lib/caddy/*.conf
    '';
  };

  # Wildcard DNS for *.$(hostname).incus → 127.0.0.1 so wget/curl work inside the container.
  # Run dnsmasq on port 5354 to avoid conflicting with systemd-resolved on port 53,
  # and tell resolved to forward .incus queries to dnsmasq.
  services.dnsmasq = {
    enable = true;
    settings = {
      address = ["/.incus/127.0.0.1"];
      local = ["/.incus/"];
      port = 5354;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-resolv = true;
    };
  };

  services.resolved.settings = {
    Resolve = {
      DNS = "127.0.0.1:5354";
      Domains = "~incus";
    };
  };

  systemd.services.ingress-sync = {
    description = "Regenerate Caddy ingress config from listening ports";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${caddyConfigScript}/bin/generate-ingress-config";
    };
    after = ["caddy.service"];
    requires = ["caddy.service"];
  };

  # Allow wheel group to restart ingress-sync without a password
  security.sudo.extraRules = [
    {
      groups = ["wheel"];
      commands = [
        {
          command = "/run/current-system/sw/bin/systemctl restart ingress-sync.service";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # Create ingress state dir and copy system CAs to bundle on every boot
  # (tmpfiles 'C' creates a symlink to the nix store instead of a real copy)
  systemd.tmpfiles.rules = ["d /var/lib/ingress 0755 root root -"];

  systemd.services.init-ingress-ca = {
    description = "Initialize ingress CA bundle";
    wantedBy = ["sysinit.target"];
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt /var/lib/ingress/ca-bundle.crt";
    };
  };

  # Point SSL tools at combined bundle (system CAs + Caddy internal CA)
  environment.variables = {
    SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
  };

  environment.systemPackages = [
    ingressScript
    ingressSyncScript
  ];
}
