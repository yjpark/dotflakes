{ pkgs, lib, ... }:
# Route a container's outbound TCP through an HTTP proxy running on the host.
#
# Why this exists: OneCLI's gateway dials upstream services directly and has no
# upstream-proxy support (https://github.com/onecli/onecli/issues/182), so
# setting HTTPS_PROXY on the OneCLI container does nothing for its egress. On
# hosts where the internet is only reachable through the host's clash proxy,
# the gateway therefore cannot reach upstream APIs at all. Fix it below the
# application: capture the container's TCP egress with an nftables REDIRECT and
# hand it to a local mihomo instance that forwards to the host proxy.
#
# mihomo rather than sing-box because its sniffer rewrites each connection's
# destination to the sniffed TLS SNI / HTTP Host (`override-destination`), which
# means:
#   - the upstream clash is asked for CONNECT <domain>:443, so its domain rules
#     still match (an IP-only chain would fall through to GEOIP/MATCH)
#   - the container's own DNS answer is discarded, so DNS poisoning is harmless
# sing-box 1.13 cannot do this: `sniff_override_destination` was removed in
# 1.13.0, and the replacement `action: "sniff"` only feeds route-rule matching —
# verified against sing-box 1.13.5, which still CONNECTs to the original IP.
let
  # Host HTTP proxy: the mihomo service declared in packs/nixos/host/clash,
  # which also opens this port to the incus zone. Reached over the incus bridge
  # gateway — incusbr0 is 10.100.0.1/24, so the host is 10.100.0.1 from inside
  # any container. Hardcoded rather than read from config.clash.httpPort,
  # because this module is evaluated in the container's configuration, which
  # does not import the host pack.
  proxyHost = "10.100.0.1";
  proxyPort = 21102;

  # Loopback port for mihomo's transparent-redirect listener. mihomo leaves
  # allow-lan off by default and so binds 127.0.0.1 only, which is all a
  # REDIRECT target needs.
  redirPort = 12345;

  # Destinations that must never be redirected: loopback (OneCLI reaches
  # postgres there), the incus bridge — and therefore the proxy itself — plus
  # LAN, link-local and multicast. Redirecting any of these would break
  # container<->host traffic and would loop mihomo's own egress back into
  # itself.
  directDests = [
    "0.0.0.0/8"
    "10.0.0.0/8"
    "127.0.0.0/8"
    "169.254.0.0/16"
    "172.16.0.0/12"
    "192.168.0.0/16"
    "224.0.0.0/4"
    "240.0.0.0/4"
  ];

  # Rendered as whole blocks rather than inline, so each generated line carries
  # its own indentation — interpolating a multi-line value into an indented
  # string literal only indents its first line.
  mihomoRules = lib.concatStringsSep "\n" (
    map (d: "  - IP-CIDR,${d},DIRECT,no-resolve") directDests
    ++ [ "  - MATCH,upstream" ]
  );

  nftDirectRules = lib.concatMapStringsSep "\n" (d: "  ip daddr ${d} return") directDests;

  # The mihomo module warns that configFile may hold proxy credentials and so
  # should not live in the world-readable store. This one does not — the clash
  # NodePort takes no auth. If that ever changes, make it a SOPS secret and
  # point services.mihomo.configFile at the decrypted path instead.
  configFile = pkgs.writeText "mihomo-egress-proxy.yaml" ''
    log-level: warning
    mode: rule

    # Transparent-redirect listener targeted by the nftables rules below.
    redir-port: ${toString redirPort}

    # Replace the destination with the sniffed domain so the upstream proxy
    # does the resolving and its domain rules apply.
    sniffer:
      enable: true
      override-destination: true
      sniff:
        TLS:
          ports: [443]
        HTTP:
          ports: [80]

    proxies:
      - name: upstream
        type: http
        server: ${proxyHost}
        port: ${toString proxyPort}

    # Keep this free of GEOIP/GEOSITE rules: matching those makes mihomo fetch
    # geodata, which it cannot do until the proxy it is configuring already
    # works. The IP-CIDR rules mirror directDests as defence in depth — the
    # nftables rules already keep that traffic away from mihomo.
    rules:
    ${mihomoRules}
  '';
in
{
  services.mihomo = {
    enable = true;
    inherit configFile;
  };

  # IPv4-only egress. The host proxy is IPv4 and only the ip family is
  # redirected below, so leaving IPv6 on would let connections to dual-stack
  # hosts bypass the proxy and hang: glibc prefers IPv4 over the incus ULA
  # address by RFC 6724 precedence, but that is a preference, not a guarantee.
  # Disabling IPv6 also makes getaddrinfo's AI_ADDRCONFIG drop AAAA records, so
  # nothing even attempts an IPv6 connection.
  networking.enableIPv6 = false;

  # Capture outbound TCP and hand it to mihomo.
  #
  # Its own table, so it cannot collide with `table inet firewalld` or
  # `table inet incus`. nftables.service only deletes the tables it declares —
  # flushRuleset defaults off for stateVersion >= 23.11 — so firewalld's
  # ruleset is left intact.
  #
  # Deliberately no `meta skuid` loop guard: mihomo runs under DynamicUser, so
  # its uid is unknowable at build time, and a name-based skuid match would fail
  # the sandboxed networking.nftables.checkRuleset build check. Excluding
  # 10.0.0.0/8 covers mihomo's own egress to the proxy instead.
  networking.nftables.tables.egress-proxy = {
    family = "ip";
    content = ''
      chain output {
        type nat hook output priority -100; policy accept;

      ${nftDirectRules}

        meta l4proto tcp redirect to :${toString redirPort}
      }
    '';
  };
}
