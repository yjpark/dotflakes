{ config, pkgs, lib, ... }:
# Host clash (mihomo) service, replacing the clash Deployment that used to run
# in k3s. Why it moved:
#
#   - circular dependency: k3s needed the proxy to pull the image that provided
#     the proxy, worked around by hand-written systemd drop-ins
#   - the Deployment, NodePort Service and ConfigMap were applied imperatively
#     and lived nowhere in this repo
#   - the pod kept ~32M of downloaded geodata and the fetched subscription lists
#     in an ephemeral filesystem, re-fetching both on every restart
#   - the only thing k3s was really providing was an ingress for the yacd
#     dashboard, whose HTTPS route was unusable anyway: the UI has to reach the
#     controller over plain HTTP, so browsers block it as mixed content
#
# mihomo serves the dashboard itself from the controller port, same origin as
# the API, so no ingress is needed and the mixed-content problem disappears.
# Dashboard: http://<host>:21109/ui/
#
# Ports are in the 211xx range rather than mihomo's usual 11xx so this can run
# alongside clash-verge (packs/nixos/host/clash-verge.nix), which owns 1100-1109.
let
  ports = {
    mixed = 21100;
    socks = 21101;
    http = 21102;
    controller = 21109;
  };

  # Subscription provider name — also its cache file name — mapped to the
  # proxy-group that selects from it. Each needs a matching entry in
  # secrets/clash.yaml.
  providers = {
    shadowsocks = "Shadowsocks";
    okcloud = "OKCloud";
  };

  secretName = provider: "clash-provider-${provider}";

  # GEOIP,CN is the only geo rule used below, so the cn+private subset is all
  # that is needed: 260K, against 23M for the full geoip.dat or 8.1M for an
  # mmdb. Shipping it from the store is also what removes the pod's bootstrap
  # problem — it downloaded geodata through the very proxy it was starting up
  # to provide.
  geoip = "${pkgs.v2ray-geoip}/share/v2ray/geoip-only-cn-private.dat";

  # The mihomo module runs the daemon with `-d /var/lib/private/mihomo` (a
  # DynamicUser StateDirectory). Relative paths in the config, and the geodata
  # files, resolve against it — and persist there, unlike in the pod.
  stateDir = "/var/lib/private/mihomo";

  # Rendered as whole blocks so each generated line carries its own
  # indentation: interpolating a multi-line value into an indented string
  # literal only indents its first line.
  providerYaml = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (provider: _: lib.concatStringsSep "\n" [
      "  ${provider}:"
      "    type: http"
      "    url: ${config.sops.placeholder.${secretName provider}}"
      "    interval: 3600"
      "    path: ./${provider}.yaml"
      "    health-check:"
      "      enable: true"
      "      interval: 600"
      "      url: http://www.gstatic.com/generate_204"
    ])
    providers);

  groupYaml = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (provider: group: lib.concatStringsSep "\n" [
      "  - name: ${group}"
      "    type: select"
      "    use:"
      "      - ${provider}"
    ])
    providers);

  # Carried over verbatim from the ConfigMap this replaces, including the
  # absence of `no-resolve` on the IP-CIDR rules — mihomo therefore resolves
  # the name before matching them, which is the behaviour that was in place.
  rulesYaml = lib.concatMapStringsSep "\n" (rule: "  - ${rule}") [
    "IP-CIDR,127.0.0.0/8,DIRECT"
    "IP-CIDR,172.16.0.0/12,DIRECT"
    "IP-CIDR,192.168.0.0/16,DIRECT"
    "IP-CIDR,10.0.0.0/8,DIRECT"
    "IP-CIDR,17.0.0.0/8,DIRECT"
    "DOMAIN-SUFFIX,local,DIRECT"
    "DOMAIN-SUFFIX,.cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "DOMAIN-SUFFIX,gstatic.com,Shadowsocks"
    "DOMAIN-SUFFIX,googleapis.com,Shadowsocks"
    "MATCH,Shadowsocks"
  ];
in
{
  options.clash = {
    httpPort = lib.mkOption {
      type = lib.types.port;
      readOnly = true;
      description = "Local HTTP proxy port served by mihomo.";
    };

    proxyUrl = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = ''
        Loopback URL of the local HTTP proxy, for anything on this host that
        needs to route through it — see mixins/nixos/cn/proxy-env.nix.
      '';
    };
  };

  config = {
    clash.httpPort = ports.http;
    clash.proxyUrl = "http://127.0.0.1:${toString ports.http}";

    services.mihomo = {
      enable = true;
      configFile = config.sops.templates."clash.yaml".path;
      webui = pkgs.metacubexd;
    };

    # The module warns that configFile may hold proxy credentials and so should
    # not sit in the world-readable store. That is exactly the case here — the
    # subscription URLs are the credentials — hence sops.templates, which
    # renders the config under /run/secrets with the URLs substituted in.
    sops.secrets = lib.genAttrs
      (map secretName (lib.attrNames providers))
      (_: { sopsFile = ./secrets/clash.yaml; });

    sops.templates."clash.yaml" = {
      restartUnits = [ "mihomo.service" ];
      content = ''
        mixed-port: ${toString ports.mixed}
        socks-port: ${toString ports.socks}
        port: ${toString ports.http}
        allow-lan: true
        external-controller: 0.0.0.0:${toString ports.controller}

        # Match GEOIP,CN against geoip.dat, installed from the store by
        # mihomo.service's ExecStartPre. Auto-update stays off so nothing is
        # fetched at runtime; the data tracks nixpkgs instead.
        geodata-mode: true
        geo-auto-update: false

        proxy-providers:
        ${providerYaml}

        proxy-groups:
        ${groupYaml}

        rules:
        ${rulesYaml}
      '';
    };

    # mihomo looks for geodata in its working directory, so place it there
    # before start. Re-copied on every restart, so a nixpkgs bump updates it.
    systemd.services.mihomo.serviceConfig.ExecStartPre =
      "${pkgs.coreutils}/bin/install -m0644 ${geoip} ${stateDir}/geoip.dat";

    # Reachable over LAN and ZeroTier, which is a personal VPN, so the
    # controller is left without an API secret as it was in k3s.
    services.firewalld.services.clash = {
      ports = map (port: { inherit port; protocol = "tcp"; })
        (lib.attrValues ports);
    };
    services.firewalld.zones.public.services = [ "clash" ];

    # Incus containers reach the host proxy at the bridge gateway
    # (10.100.0.1:21102) — see mixins/nixos/services/egress-proxy.nix. Only the
    # HTTP proxy port is opened to them, not the whole clash service.
    services.firewalld.zones.incus.ports = [
      { port = ports.http; protocol = "tcp"; }
    ];
  };
}
