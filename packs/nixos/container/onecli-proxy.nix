{ pkgs, lib, ... }: let
  noProxy = lib.concatStringsSep "," [
    "localhost"
    "127.0.0.1"
    "::1"
    "anthropic.com"
    ".anthropic.com"
    "claude.ai"
    ".claude.ai"
    "claude.com"
    ".claude.com"
  ];
in {
  # Route agent HTTPS traffic through OneCLI for credential injection.
  # OneCLI intercepts HTTPS, injects real API keys, and forwards — agents use placeholder keys.
  #
  # OneCLI runs in the dedicated incus container at 10.100.0.2:
  #   Dashboard:  http://10.100.0.2:10254
  #   Proxy:      http://10.100.0.2:10255
  #
  # The authenticated proxy URL (http://x:<api_key>@10.100.0.2:10255) is written to
  # /etc/onecli-proxy-auth by the onecli-seed-secrets service on the host after each
  # nixos-rebuild switch. This file is sourced by the profile.d script below.
  #
  # The OneCLI CA cert is written to /var/lib/onecli/ca.crt by the host seeder;
  # listing it in ingress.extraCaFiles (ingress.nix) merges it into the CA
  # bundle at boot and whenever it changes.

  # Stable directory for OneCLI CA cert written by the host seeder
  systemd.tmpfiles.rules = [ "d /var/lib/onecli 0755 root root -" ];

  ingress.extraCaFiles = [ "/var/lib/onecli/ca.crt" ];

  environment.variables = {
    # Node.js needs its own CA config (doesn't use system trust store)
    NODE_EXTRA_CA_CERTS = "/var/lib/onecli/ca.crt";
    NODE_USE_ENV_PROXY = "1";

    # Anthropic bypasses OneCLI: the gateway refuses hosts it holds no
    # credential for, and agents bring their own Anthropic login. These
    # connections go out directly and are captured by the egress proxy
    # (egress-proxy.nix in this pack), which sends them through host clash.
    NO_PROXY = noProxy;
    no_proxy = noProxy;
  };

  # Sources /etc/onecli-proxy-auth (written by host seeder) to set authenticated proxy URL.
  # For bash/POSIX login shells via profile.d:
  environment.etc."profile.d/onecli-proxy.sh".text = ''
    if [ -r /etc/onecli-proxy-auth ]; then
      . /etc/onecli-proxy-auth
      export HTTPS_PROXY HTTP_PROXY
    fi
  '';
  # Fish shell sourcing is handled by Home Manager in packs/home/container/onecli-proxy.nix.
}
