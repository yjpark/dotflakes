---
# flakes-i9ao
title: Route onecli container egress through host clash proxy
status: in-progress
type: feature
priority: normal
created_at: 2026-10-05T13:07:49Z
updated_at: 2026-10-05T13:45:49Z
parent: flakes-qbvb
---

OneCLI's Rust gateway dials upstream services **directly** — it has no upstream
forward-proxy support (upstream issue https://github.com/onecli/onecli/issues/182,
still open, no maintainer response, no PR). Setting `HTTPS_PROXY` in
`virtualisation.oci-containers.containers.onecli.environment`
(`nixos/containers/onecli/service.nix`) therefore does **not** affect gateway
egress.

On CN-side hosts the only route to the internet is the clash proxy running as a
k3s NodePort, so the `onecli` container cannot reach upstream APIs at all. Fixed
below the application: an nftables REDIRECT captures the container's outbound
TCP and hands it to a local mihomo instance that forwards to the host's clash
proxy, rewriting each connection's destination to the sniffed TLS SNI.

Chain: agent in `yolo` → `onecli:10255` (injects credentials) → mihomo in the
onecli container → `10.100.0.1:31102` (host clash) → upstream.

## Verified environment facts

- clash is a k3s NodePort in ns `services`: `31102` → `1102` (http),
  `31101` → `1101` (socks5), `31109` → `1109` (control).
- Both `pc` and `edger` run k3s (via the autowired `mixins/nixos/ext4`, which
  includes `k3s.ext4.nix`), so `31102` exists on both.
- `incusbr0` is `10.100.0.1/24` with `ipv4.nat = true`, so from inside any incus
  container the host's clash proxy is at **`10.100.0.1:31102`**.
- firewalld backend is `nftables` and `networking.nftables.enable = true` (set
  by `packs/nixos/common/settings/firewalld.nix`);
  `networking.firewall.enable = false` — firewalld replaces it.
- The onecli container's `system.stateVersion` is `26.05`, so
  `networking.nftables.flushRuleset` defaults to **false** — nftables.service
  only deletes the tables it declares and leaves firewalld's ruleset intact.
- `onecli` is deployed on `edger` (`nixos/hosts/edger/imports.nix`); `pc` does
  **not** yet import `mixins/nixos/services/onecli` or
  `mixins/nixos/services/incus-ingress.nix`.

## Design decisions

- **mihomo, not sing-box.** The whole point is for the upstream clash to receive
  `CONNECT <domain>:443` rather than `CONNECT <ip>:443`, so that its domain
  rules still match and the container's (poisoned) DNS answers become
  irrelevant. mihomo's `sniffer.override-destination` does exactly that.
  **sing-box 1.13 cannot**: `sniff_override_destination` was *removed* in
  1.13.0, and the replacement `action: "sniff"` only feeds route-rule matching.
  Verified empirically against sing-box 1.13.5 and mihomo 1.19.23 — see
  "Verification performed" below.
- **redsocks was rejected.** It only ever issues `CONNECT <ip>:<port>`, so
  clash's domain rules would be bypassed and a separate clean-DNS story (local
  DoH resolver) would be mandatory. It is also a dead end in this repo: the
  `services.redsocks` module applies its iptables rules via
  `networking.firewall.extraCommands`, which never runs because firewalld is
  used instead of the NixOS iptables firewall.
- **`redirect`, not `tun`.** A tun inbound would also catch UDP but needs
  `/dev/net/tun` added to the container — an imperative step outside Nix.
- **No `meta skuid` loop guard** in the nftables rules: mihomo runs under
  `DynamicUser`, so its uid is unknowable at build time, and a name-based
  `skuid` match fails the sandboxed `networking.nftables.checkRuleset` build
  check. Excluding `10.0.0.0/8` covers mihomo's own egress to the proxy.
- **`networking.enableIPv6 = false`** in the mixin. The host proxy is IPv4 and
  only the `ip` family is redirected, so leaving IPv6 on would let connections
  to dual-stack hosts silently bypass the proxy and hang. glibc prefers IPv4
  over the incus ULA address by RFC 6724 precedence, but that is a preference,
  not a guarantee. Disabling IPv6 also makes `getaddrinfo`'s `AI_ADDRCONFIG`
  drop AAAA records so nothing even attempts IPv6.
- **No GEOIP/GEOSITE rules** in the mihomo config: matching those makes mihomo
  fetch geodata, which it cannot do until the proxy it is configuring already
  works.
- **Reusable mixin**, so `searxng` / other containers can opt in later.

## Verification performed

Reproduced the whole data path on `pc` before writing any Nix, using a
throwaway nftables table (`ip daddr 198.51.100.7 tcp dport 443 redirect to
:12345`) plus a logging CONNECT proxy, and `curl --resolve
example.com:443:198.51.100.7` so the destination IP was deliberately bogus:

- **sing-box 1.13.5** with `action: "sniff"` → upstream received
  `CONNECT 198.51.100.7:443` — the IP. Destination override is gone.
- **sing-box 1.13.5** with legacy `sniff_override_destination: true` → refused
  to start: *"legacy inbound fields are deprecated in sing-box 1.11.0 and
  removed in sing-box 1.13.0"*.
- **mihomo 1.19.23** with `sniffer.override-destination: true` → upstream
  received `CONNECT example.com:443`. The bogus IP was discarded in favour of
  the sniffed SNI.
- **End-to-end against the real clash** on `31102`: `http_code=200`, and mihomo
  logged `[TCP] ... --> example.com:443 match Match using upstream`.

Build-time verification after implementation:

- `nixosConfigurations.onecli.config.system.build.toplevel` builds, which
  includes the sandboxed `networking.nftables.checkRuleset` validation of the
  generated ruleset.
- The generated mihomo config passes `mihomo -t`
  (*"configuration file ... test is successful"*).
- `pc` and `edger` toplevels still evaluate (`nix build --dry-run`), and both
  show `31102/tcp` in `services.firewalld.zones.incus.ports`.

## Summary of Changes

### `mixins/nixos/services/egress-proxy.nix` (new)

Container-side mixin, parameterised via `let` bindings (`proxyHost`,
`proxyPort`, `redirPort`, `directDests`) in the style of
`mixins/nixos/services/incus-ingress.nix`:

- `services.mihomo` with a generated config: `redir-port` on loopback,
  `sniffer.override-destination: true` (TLS:443, HTTP:80), a single `http`
  proxy pointing at `10.100.0.1:31102`, and `IP-CIDR ... DIRECT` +
  `MATCH,upstream` rules.
- `networking.nftables.tables.egress-proxy` — its own `ip` table with a
  `nat hook output` chain that returns for loopback / incus bridge / LAN /
  link-local / multicast and redirects all other TCP to the mihomo port.
- `networking.enableIPv6 = false`.

### `packs/nixos/host/incus.nix`

Added `{ port = 31102; protocol = "tcp"; }` to
`services.firewalld.zones.incus.ports` so containers can reach the host's clash
NodePort. Applies to every host, which is the intent.

### `nixos/containers/onecli/imports.nix`

Imports the new mixin.

### `nixos/containers/onecli/service.nix`

`podman-onecli` now has `after`/`wants` on `mihomo.service`. The nftables
REDIRECT is installed before `network-pre.target`, so without this every
outbound connection during boot — including the `ghcr.io/onecli/onecli:latest`
image pull — is redirected to a closed port and refused.

## Side benefit

The image pull and the `curl` calls in `mixins/nixos/services/onecli/*.bash`
now go through clash too; previously they went direct and would fail on
CN-side hosts.

## Known limitation

Names that resolve to **AAAA only** will not work, since IPv6 is disabled and
the redirect is IPv4-only. None of the hosts OneCLI targets are in that
category (`api.anthropic.com`, `github.com`, `context7.com` all have A
records). If it ever matters, the fix is mihomo's `dns` section in **fake-ip**
mode plus pointing the container's `resolv.conf` at mihomo, which makes every
name resolve to a synthetic IPv4 that mihomo maps back to the domain.

## Tasks

- [x] Create `mixins/nixos/services/egress-proxy.nix`
- [x] Open `31102/tcp` in `services.firewalld.zones.incus` (`packs/nixos/host/incus.nix`)
- [x] Import the mixin from `nixos/containers/onecli/imports.nix`
- [x] Order `podman-onecli` after `mihomo.service`
- [x] Confirm the destination is rewritten to the sniffed domain, not the IP (mihomo 1.19.23 verified; sing-box 1.13.5 ruled out)
- [x] Confirm no loop: mihomo's own egress to `10.100.0.1:31102` falls under the `10.0.0.0/8` exclusion
- [x] Build `nixosConfigurations.onecli` incl. nftables `checkRuleset`, and `mihomo -t` the generated config
- [ ] Deploy to `edger` and verify in situ: `incus exec onecli -- curl -sS https://api.anthropic.com` reaches upstream and clash logs the request **by domain**
- [ ] Verify the gateway path end-to-end from `yolo` (agent → onecli → mihomo → clash → upstream)
- [ ] Check the boot-time ordering holds in practice (mihomo up before the image pull)

## Deferred

`pc` host enablement of onecli needs `mixins/nixos/services/onecli` and
`mixins/nixos/services/incus-ingress.nix` added to `nixos/hosts/pc/imports.nix`,
which drags in the Caddy ingress, the Cloudflare secret and the `10.100.0.x`
static-IP scheme. Worth its own bean.
