{ pkgs, lib, config, ... }:
let
  # Containers with ingress enabled.
  # Each entry needs a static IP assigned via:
  #   incus config device override <name> eth0 ipv4.address=<ip>
  ingressContainers = [
    { name = "onecli"; ip = "10.100.0.2"; }
    { name = "searxng"; ip = "10.100.0.3"; }
    { name = "yolo"; ip = "10.100.0.100"; }
    { name = "spacebot"; ip = "10.100.0.101"; }
    { name = "hermes"; ip = "10.100.0.102"; }
  ];

  # Domain for LAN-facing ingress (host-level Caddy).
  # DNS: *.${hostName}.${domain} → host's ZeroTier IP (one wildcard A record per host on Cloudflare).
  # URL pattern: ${container}-${port}.${hostName}.${domain} → http://${container.ip}:${port}
  # e.g., yolo-8080.edger.yjpark.org → http://10.100.0.100:8080
  domain = "yjpark.org";

  # Caddy built with the Cloudflare DNS plugin for ACME DNS-01 challenge.
  # ZeroTier IPs are private so HTTP-01/TLS-ALPN-01 are not reachable by Let's Encrypt.
  # IMPORTANT: replace lib.fakeHash with the real hash after the first failed build.
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
    hash = "sha256-bL1cpMvDogD/pdVxGA8CAMEXazWpFDBiGBxG83SmXLA=";
  };

  # Generate per-container matcher + handle blocks for the Caddyfile.
  # vars_regexp captures the port from the subdomain prefix (e.g., "yolo-8080").
  containerBlocks = lib.concatMapStrings
    (c: ''
      @${c.name} vars_regexp ${c.name} {http.request.host} ^${c.name}-(?P<port>\d+)\.${config.networking.hostName}\.${domain}$
      handle @${c.name} {
        reverse_proxy ${c.ip}:80 {
          header_up Host {re.${c.name}.port}.${c.name}.incus
        }
      }
    '')
    ingressContainers;

  # Hub blocks: <container>-hub.<host>.<domain> → container's hub page
  hubBlocks = lib.concatMapStrings
    (c: ''
      @${c.name}-hub expression `{http.request.host} == "${c.name}-hub.${config.networking.hostName}.${domain}"`
      handle @${c.name}-hub {
        reverse_proxy ${c.ip}:80 {
          header_up Host hub.${c.name}.incus
        }
      }
    '')
    ingressContainers;

  # Static named-service blocks (exact hostname match, must come before containerBlocks).
  staticBlocks = ''
    ${hubBlocks}
    @onecli expression `{http.request.host} == "onecli.${config.networking.hostName}.${domain}"`
    handle @onecli {
      reverse_proxy 10.100.0.2:10254
    }
  '';

  caddyConfigFile = pkgs.writeText "Caddyfile" ''
    {
      log {
        level ERROR
      }
    }

    # HTTPS with Let's Encrypt wildcard cert via Cloudflare DNS-01
    *.${config.networking.hostName}.${domain} {
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }

      ${staticBlocks}
      ${containerBlocks}
      handle {
        respond "Unknown service" 404
      }
    }

    # HTTP fallback (same routing, no TLS)
    http://*.${config.networking.hostName}.${domain} {
      ${staticBlocks}
      ${containerBlocks}
      handle {
        respond "Unknown service" 404
      }
    }
  '';

  pullCaCertScript = pkgs.writeShellApplication {
    name = "incus-pull-ca";
    runtimeInputs = with pkgs; [ incus coreutils ];
    text = ''
      CADDY_CA_PATH=".local/share/caddy/pki/authorities/local/root.crt"
      SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
      COMBINED="/var/lib/ingress/ca-bundle.crt"

      mkdir -p "$(dirname "$COMBINED")"
      cp "$SYSTEM_CA" "$COMBINED"

      CONTAINERS=(${lib.concatStringsSep " " (map (c: c.name) ingressContainers)})
      for CONTAINER in "''${CONTAINERS[@]}"; do
        if ! incus info "$CONTAINER" 2>/dev/null | grep -q "Status: RUNNING"; then
          echo "SKIP: $CONTAINER is not running"
          continue
        fi
        TMPFILE=$(mktemp)
        if incus file pull "$CONTAINER/var/lib/caddy/$CADDY_CA_PATH" "$TMPFILE" 2>/dev/null; then
          cat "$TMPFILE" >> "$COMBINED"
          echo "OK: Added CA from $CONTAINER"
        else
          echo "SKIP: $CONTAINER has no Caddy CA yet (run ingress-sync inside it first)"
        fi
        rm -f "$TMPFILE"
      done

      echo "CA bundle updated at $COMBINED. Restart your browser to pick up changes."
    '';
  };
in
{
  # Disable k3s's bundled Traefik ingress controller when k3s is enabled,
  # so its iptables DNAT rules don't intercept ports 80/443 before host Caddy.
  services.k3s.extraFlags = lib.mkIf config.services.k3s.enable [ "--disable=traefik" ];

  # dnsmasq on port 5354 for *.incus wildcard DNS resolution.
  # Uses address rules with static IPs — dnsmasq's cname requires the target
  # to be locally known, which forwarded entries are not.
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 5354;
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      no-resolv = true;
      address = map (c: "/.${c.name}.incus/${c.ip}") ingressContainers;
    };
  };

  # systemd-resolved as primary resolver, forwarding .incus to dnsmasq
  services.resolved = {
    enable = true;
  };

  services.resolved.settings.Resolve = {
    DNS = "127.0.0.1:5354";
    Domains = "~incus";
    DNSOverTLS = "opportunistic";
    FallbackDNS = "1.1.1.1 8.8.8.8";
  };

  # Host-level Caddy reverse proxy: *.${hostName}.yjpark.org → container services
  # Cloudflare API token is read from the SOPS-decrypted env file at runtime.
  # Secret file: mixins/nixos/services/secrets/cloudflare-caddy.txt (create manually)
  # Content: CLOUDFLARE_API_TOKEN=<token-with-Zone/DNS/Edit-permission>
  services.caddy = {
    enable = true;
    package = caddyWithCloudflare;
    configFile = caddyConfigFile;
  };

  sops.secrets."cloudflare-caddy-env" = {
    sopsFile = ./secrets/cloudflare-caddy.txt;
    format = "binary";
    owner = "caddy";
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile =
    config.sops.secrets."cloudflare-caddy-env".path;

  # Open HTTP and HTTPS on the public zone (covers ZeroTier interface) for LAN access
  services.firewalld.zones.public.services = [ "http" "https" ];

  # Create ingress state dir and copy system CAs to bundle on every boot
  systemd.tmpfiles.rules = [ "d /var/lib/ingress 0755 root root -" ];

  systemd.services.init-ingress-ca = {
    description = "Initialize ingress CA bundle";
    wantedBy = [ "sysinit.target" ];
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/cp --remove-destination /etc/ssl/certs/ca-certificates.crt /var/lib/ingress/ca-bundle.crt";
    };
  };

  # Point SSL tools at combined bundle; run incus-pull-ca to add Caddy's CA
  environment.variables = {
    SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
    NIX_SSL_CERT_FILE = "/var/lib/ingress/ca-bundle.crt";
  };

  environment.systemPackages = [ pullCaCertScript ];
}
