{ pkgs
, lib
, config
, ...
}:
# Container side of the incus ingress. The host (mixins/nixos/services/incus-ingress.nix)
# routes <container>-<port>.<host>.yjpark.org to this container's port 80 with
# Host <port>.<container>.incus, and serves the hub page that lists every port.
#
# Caddy is still needed here even though discovery moved to the host: dev
# servers commonly bind 127.0.0.1, which the host cannot reach, and agents in
# the container use <port>.<container>.incus to test their own servers. One
# static wildcard route covers every port, so nothing is regenerated when a
# server starts or stops.
let
  domain = "${config.networking.hostName}.incus";
  bundle = "/var/lib/ingress/ca-bundle.crt";
  caddyCa = "/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt";

  # Strip the headers that stop the host hub page from embedding a service.
  portRoute = ''
    @port vars_regexp port {http.request.host} ^(\d+)\.${lib.escapeRegex domain}$
    handle @port {
      reverse_proxy localhost:{re.port.1} {
        header_down -X-Frame-Options
        header_down -Content-Security-Policy
        header_down -Content-Security-Policy-Report-Only
      }
    }
    handle {
      respond "Unknown service" 404
    }
  '';

  ingressScript = pkgs.writeShellApplication {
    name = "ingress";
    runtimeInputs = with pkgs; [ iproute2 gawk hostname gnugrep coreutils ];
    text = builtins.readFile ./ingress-scripts/ingress.bash;
  };

  # Rebuilt from scratch every run, so CAs are never appended twice and one
  # writer never drops another's CA.
  rebuildBundle = pkgs.writeShellScript "rebuild-ingress-ca-bundle" ''
    TMP=$(${pkgs.coreutils}/bin/mktemp ${bundle}.XXXXXX)
    ${pkgs.coreutils}/bin/cat /etc/ssl/certs/ca-certificates.crt > "$TMP"
    for CA in ${lib.escapeShellArgs config.ingress.extraCaFiles}; do
      if [ -f "$CA" ]; then
        ${pkgs.coreutils}/bin/cat "$CA" >> "$TMP"
        echo "ingress-ca-bundle: added $CA"
      fi
    done
    ${pkgs.coreutils}/bin/chmod 644 "$TMP"
    ${pkgs.coreutils}/bin/mv "$TMP" ${bundle}
  '';
in
{
  options.ingress.extraCaFiles = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = ''
      CA certificates appended to ${bundle} (the SSL_CERT_FILE bundle) when
      present. The bundle is rebuilt whenever one of them changes.
    '';
  };

  config = {
    services.caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        {
          log {
            level ERROR
          }
          auto_https disable_redirects
        }

        *.${domain} {
          tls internal
          ${portRoute}
        }

        http://*.${domain} {
          ${portRoute}
        }
      '';
    };

    # Wildcard DNS for *.incus → 127.0.0.1 so wget/curl work inside the container.
    # Run dnsmasq on port 5354 to avoid conflicting with systemd-resolved on port 53,
    # and tell resolved to forward .incus queries to dnsmasq.
    services.dnsmasq = {
      enable = true;
      settings = {
        address = [ "/.incus/127.0.0.1" ];
        local = [ "/.incus/" ];
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

    ingress.extraCaFiles = [ caddyCa ];

    systemd.tmpfiles.rules = [ "d /var/lib/ingress 0755 root root -" ];

    # Seed the bundle with the system CAs early, so SSL_CERT_FILE is valid
    # before anything that needs TLS starts.
    systemd.services.init-ingress-ca = {
      description = "Initialize ingress CA bundle";
      wantedBy = [ "sysinit.target" ];
      before = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt ${bundle}";
      };
    };

    # Add the extra CAs (Caddy's internal CA, OneCLI's) at boot and again
    # whenever one of them is created or changed.
    systemd.services.ingress-ca-bundle = {
      description = "Rebuild ingress CA bundle with extra CAs";
      wantedBy = [ "multi-user.target" ];
      after = [ "init-ingress-ca.service" "systemd-tmpfiles-setup.service" "caddy.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${rebuildBundle}";
      };
    };

    systemd.paths.ingress-ca-bundle = {
      description = "Watch extra CAs for the ingress CA bundle";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = config.ingress.extraCaFiles;
    };

    # Point SSL tools at combined bundle (system CAs + extra CAs)
    environment.variables = {
      SSL_CERT_FILE = bundle;
      NIX_SSL_CERT_FILE = bundle;
    };

    environment.systemPackages = [ ingressScript ];
  };
}
