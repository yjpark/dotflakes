{ config, lib, ... }:
# Proxy environment for the daemons that fetch from the internet on their own
# behalf, rather than through a user's shell.
#
# Replaces six imperative scripts — sync-/reset-/show-proxy_{nix-daemon,k3s,
# containerd} — which wrote /run/systemd/system/<svc>.service.d/override.conf
# from whatever happened to be set in the invoking shell and then restarted the
# service. Living under /run, they evaporated on every reboot.
#
# This lives under cn/ rather than lan/<site> or alongside the clash service
# because it belongs to "this host is behind the CN firewall", which is
# orthogonal to both which LAN a host sits on and whether it runs clash. g1 is
# on no LAN at all but still needs it.
#
# Requires packs/nixos/host/clash for config.clash.proxyUrl. Every host imports
# that pack via packs/nixos/host, so importing cn/ without it fails loudly at
# evaluation rather than silently doing nothing.
let
  proxy = config.clash.proxyUrl;

  # Both substituters are reachable directly from CN, so keep store traffic off
  # the proxy — routing it through clash would be slower and would spend
  # subscription bandwidth on content that does not need it.
  #
  # The private ranges also cover the k3s pod and service CIDRs (10.42/10.43)
  # and the incus bridge (10.100.0.0/24), all inside 10.0.0.0/8.
  #
  # curl has honoured CIDR notation in NO_PROXY since 7.86 — verified here
  # against 8.18 with a dead proxy and a non-matching control — and Go's
  # httpproxy, which k3s uses, has supported it for longer.
  noProxy = lib.concatStringsSep "," [
    "localhost"
    "127.0.0.1"
    "::1"
    "mirrors.tuna.tsinghua.edu.cn"
    "cache.nixos.org"
    "10.0.0.0/8"
    "172.22.0.0/16"
    ".yjpark.org"
    ".yjpark.zerotier"
    ".incus"
  ];

  # Lowercase only, deliberately. curl reads the lowercase names, Nix propagates
  # exactly these into fixed-output derivation builders via impureEnvVars, and
  # Go falls back to lowercase when the uppercase form is absent. NIX_CURL_FLAGS
  # from the old scripts is dropped: modern Nix does not read it.
  env = {
    http_proxy = proxy;
    https_proxy = proxy;
    all_proxy = proxy;
    no_proxy = noProxy;
  };
in
{
  # nix-daemon performs all substituter and fixed-output fetching. A user's
  # shell proxy never reaches it, which is why `mise run _switch-host` only
  # ever proxied flake-input fetches — those happen in the client. The daemon
  # reads this env at start but only uses it at fetch time, so it needs no
  # ordering against mihomo.
  systemd.services.nix-daemon.environment = env;

  # k3s and containerd pull images. Ordering after mihomo is safe now that the
  # proxy is a plain systemd unit with nothing to pull itself — that
  # circularity is precisely what made this imperative in the first place.
  systemd.services.k3s = lib.mkIf config.services.k3s.enable {
    environment = env;
    after = [ "mihomo.service" ];
    wants = [ "mihomo.service" ];
  };

  systemd.services.containerd = lib.mkIf config.virtualisation.containerd.enable {
    environment = env;
    after = [ "mihomo.service" ];
    wants = [ "mihomo.service" ];
  };
}
