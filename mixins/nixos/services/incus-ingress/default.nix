{ pkgs, lib, config, ... }:
# Host ingress: one Caddy for *.<host>.<domain>, with a hub page listing every
# service on this host and its incus containers.
#
#   hub.<host>.<domain>             hub page (this host's services, each
#                                   container's live ports, the other sites)
#   <service>.<host>.<domain>       ingress.services entries with an upstream
#   <container>-<port>.<host>...    a container port, via the container's Caddy
#
# Options live in packs/nixos/host/ingress.nix so service modules can register
# links on any host; this mixin is what serves them.
let
  cfg = config.ingress;
  host = config.networking.hostName;
  zone = "${host}.${cfg.domain}";

  # Containers that should exist on every host running the ingress.
  defaultContainers = [
    # No Caddy inside (it imports neither the container pack nor ingress.nix);
    # its services listen on all interfaces, so they are reached directly.
    { name = "onecli"; ip = "10.100.0.2"; viaCaddy = false; }
    { name = "searxng"; ip = "10.100.0.3"; }
    { name = "yolo"; ip = "10.100.0.100"; }
  ];

  # Loopback port of the hub API (container discovery, favicons).
  apiPort = 9998;

  # Caddy built with the Cloudflare DNS plugin for ACME DNS-01 challenge.
  # ZeroTier IPs are private so HTTP-01/TLS-ALPN-01 are not reachable by Let's Encrypt.
  caddyWithCloudflare = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@v0.2.3" ];
    hash = "sha256-bL1cpMvDogD/pdVxGA8CAMEXazWpFDBiGBxG83SmXLA=";
  };

  # Removing these lets the hub page embed the service in its iframe.
  stripFrameHeaders = ''
    header_down -X-Frame-Options
    header_down -Content-Security-Policy
    header_down -Content-Security-Policy-Report-Only
  '';

  embedded = lib.filterAttrs (_: s: s.upstream != null) cfg.services;

  # What the hub page renders. Generated at build time; the page fetches the
  # containers' live ports from the API separately.
  links = {
    inherit host;
    inherit (cfg) domain;
    containers = map (c: c.name) cfg.containers;
    sites = map (s: { name = s; url = "https://hub.${s}.${cfg.domain}/"; })
      (lib.filter (s: s != host) cfg.sites);
    services = lib.mapAttrsToList
      (name: s: {
        inherit name;
        inherit (s) title group note;
        embed = s.upstream != null;
        url = if s.upstream != null then "https://${name}.${zone}${s.path}" else s.url;
      })
      cfg.services;
  };

  hubSite = pkgs.runCommand "ingress-hub-site" { } ''
    mkdir -p $out
    cp ${./hub-index.html} $out/index.html
    cp ${pkgs.writeText "links.json" (builtins.toJSON links)} $out/links.json
  '';

  hubBlock = ''
    @hub host hub.${zone}
    handle @hub {
      handle /api/* {
        reverse_proxy 127.0.0.1:${toString apiPort}
      }
      handle {
        header /links.json Cache-Control no-cache
        root * ${hubSite}
        file_server
      }
    }
  '';

  serviceBlocks = lib.concatStrings (lib.mapAttrsToList
    (name: s: ''
      @svc-${name} host ${name}.${zone}
      handle @svc-${name} {
        reverse_proxy ${s.upstream} {
          ${stripFrameHeaders}
        }
      }
    '')
    embedded);

  # vars_regexp captures the port from the subdomain prefix (e.g., "yolo-8080").
  # Containers with ingress.nix go through their own Caddy, which reaches
  # services bound to the container's localhost and strips the frame headers.
  containerBlocks = lib.concatMapStrings
    (c: ''
      @${c.name} vars_regexp ${c.name} {http.request.host} ^${c.name}-(?P<port>\d+)\.${lib.escapeRegex zone}$
      handle @${c.name} {
        ${if c.viaCaddy then ''
          reverse_proxy ${c.ip}:80 {
            header_up Host {re.${c.name}.port}.${c.name}.incus
          }
        '' else ''
          reverse_proxy ${c.ip}:{re.${c.name}.port} {
            ${stripFrameHeaders}
          }
        ''}
      }
    '')
    cfg.containers;

  routes = ''
    ${hubBlock}
    ${serviceBlocks}
    ${containerBlocks}
    handle {
      respond "Unknown service" 404
    }
  '';

  caddyConfigFile = pkgs.writeText "Caddyfile" ''
    {
      log {
        level ERROR
      }
    }

    # HTTPS with Let's Encrypt wildcard cert via Cloudflare DNS-01
    *.${zone} {
      tls {
        dns cloudflare {env.CLOUDFLARE_API_TOKEN}
      }
      ${routes}
    }

    # HTTP fallback (same routing, no TLS)
    http://*.${zone} {
      ${routes}
    }
  '';

  hubApi = pkgs.writeScriptBin "ingress-hub-api" ''
    #!${pkgs.python3}/bin/python3
    ${builtins.readFile ./hub-api.py}
  '';

  hubApiConfig = pkgs.writeText "ingress-hub-api.json" (builtins.toJSON {
    port = apiPort;
    inherit (cfg) containers;
    # Caddy admin, dnsmasq/LLMNR, the MCP OAuth bridge (listening whether or
    # not an OAuth flow is running), and the egress-proxy redirect port.
    hiddenPorts = [ 2019 5354 5355 3118 12345 ];
  });

  pullCaCertScript = pkgs.writeShellApplication {
    name = "incus-pull-ca";
    runtimeInputs = with pkgs; [ incus coreutils ];
    text = ''
      CADDY_CA_PATH=".local/share/caddy/pki/authorities/local/root.crt"
      SYSTEM_CA="/etc/ssl/certs/ca-certificates.crt"
      COMBINED="/var/lib/ingress/ca-bundle.crt"

      mkdir -p "$(dirname "$COMBINED")"
      cp "$SYSTEM_CA" "$COMBINED"

      CONTAINERS=(${lib.concatStringsSep " " (map (c: c.name) cfg.containers)})
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
          echo "SKIP: $CONTAINER has no Caddy CA yet"
        fi
        rm -f "$TMPFILE"
      done

      echo "CA bundle updated at $COMBINED. Restart your browser to pick up changes."
    '';
  };
in
{
  ingress.containers = defaultContainers;

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
      address = map (c: "/.${c.name}.incus/${c.ip}") cfg.containers;
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

  # Host-level Caddy reverse proxy: *.${host}.yjpark.org → host and container services
  # Cloudflare API token is read from the SOPS-decrypted env file at runtime.
  # Secret file: mixins/nixos/services/secrets/cloudflare-caddy.txt
  # Content: CLOUDFLARE_API_TOKEN=<token-with-Zone/DNS/Edit-permission>
  services.caddy = {
    enable = true;
    package = caddyWithCloudflare;
    configFile = caddyConfigFile;
  };

  sops.secrets."cloudflare-caddy-env" = {
    sopsFile = ../secrets/cloudflare-caddy.txt;
    format = "binary";
    owner = "caddy";
  };

  systemd.services.caddy.serviceConfig.EnvironmentFile =
    config.sops.secrets."cloudflare-caddy-env".path;

  # Hub API: lists each container's listening ports through `incus exec`, so
  # containers need no discovery agent of their own. incus-admin is what grants
  # access to the incus socket.
  users.users.ingress-hub = {
    isSystemUser = true;
    group = "ingress-hub";
    extraGroups = [ "incus-admin" ];
  };
  users.groups.ingress-hub = { };

  systemd.services.ingress-hub-api = {
    description = "Ingress hub API (container port discovery)";
    wantedBy = [ "multi-user.target" ];
    after = [ "incus.service" ];
    path = [ config.virtualisation.incus.package ];
    environment = {
      HUB_CONFIG = hubApiConfig;
      # The incus client keeps its config under $HOME/.config/incus.
      HOME = "/var/lib/ingress-hub";
    };
    serviceConfig = {
      ExecStart = "${hubApi}/bin/ingress-hub-api";
      User = "ingress-hub";
      Group = "ingress-hub";
      StateDirectory = "ingress-hub";
      Restart = "always";
      RestartSec = 5;
    };
  };

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
