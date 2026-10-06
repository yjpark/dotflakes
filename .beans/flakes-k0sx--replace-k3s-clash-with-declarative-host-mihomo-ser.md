---
# flakes-k0sx
title: Replace k3s clash with declarative host mihomo service
status: in-progress
type: feature
priority: normal
created_at: 2026-10-05T14:21:06Z
updated_at: 2026-10-06T05:48:30Z
parent: flakes-qbvb
blocked_by:
    - flakes-dw38
---

Replace the clash-in-k3s deployment with a declarative `services.mihomo` host
service, and make the proxy environment for `nix-daemon` / `k3s` / `containerd`
static Nix config instead of imperative systemd drop-ins.

## Prerequisite

[[flakes-dw38]] restructures the `lan` mixins into per-site `lan/{102,401,708}`
and creates `mixins/nixos/cn/`, which is where this bean's `proxy-env.nix` goes.
Until that lands there is no mixin that covers every CN host.

`g1` is confirmed to be a clash host (site 708), so the autowired pack is the
right shape — every host wants the service.

## Problems being fixed

- **Circular dependency.** clash runs as a k3s Deployment, so `k3s` and
  `containerd` need the proxy in order to pull the image that *provides* the
  proxy. Every sync script works around this by hand.
- **Undeclared state.** The `clash` Deployment, its NodePort Service and the
  `clash-config` ConfigMap, plus the `yacd` Deployment/Service/Ingress, were
  applied imperatively (152 days ago) and exist nowhere in this repo.
- **Six imperative scripts** in `packs/home/host/common/scripts/nixos/proxy/`
  (`sync-`/`reset-`/`show-proxy_{nix-daemon,k3s,containerd}`) write
  `/run/systemd/system/<svc>.service.d/override.conf` from whatever is in the
  current shell, then `daemon-reload` and **restart the service**. Living in
  `/run`, they evaporate on reboot.
- **The ingress was the only reason for k3s**, and its HTTPS half is unusable:
  `yacd` served over TLS at `clash-ui.pc.yjpark.org` cannot reach clash's
  controller over plain HTTP (mixed content), so only the port-80 route works.

## The insight that unblocks it

`services.mihomo` has a `webui` option and **`metacubexd` is packaged in
nixpkgs** (1.244.2). mihomo serves the dashboard itself from the
external-controller port (`-ext-ui`), i.e. same origin as the API. That removes
the mixed-content problem *and* the need for any ingress — which was the only
thing keeping clash in k3s.

`yacd` is **not** in nixpkgs, so the dashboard changes to metacubexd.

## Verified facts

- Live clash is `docker.io/metacubex/mihomo:latest` with config from the
  `clash-config` ConfigMap — so the engine is already mihomo; this is a
  packaging change, not an engine change.
- That config is only **46 lines** and uses `proxy-providers`, so the sole
  secret is the subscription URL. Current keys: `socks-port: 1101`,
  `port: 1102`, `allow-lan: true`, `external-controller: 0.0.0.0:1109`,
  `proxy-providers`, `proxy-groups`, `rules`.
- `sops-nix` in this flake supports `sops.templates.<name>.content`,
  `sops.placeholder.<secret>` and `restartUnits` — so a Nix-authored config with
  the subscription URL injected at activation is possible without a wrapper
  script.
- The `services.mihomo` unit runs `-d /var/lib/private/mihomo` under
  `DynamicUser` + `StateDirectory`, so **relative** `proxy-providers` paths
  persist across restarts in the state dir.
- `curl` 8.18 **does** honour CIDR notation in `NO_PROXY` (tested against a
  dead proxy, with a non-matching control that correctly failed), so CIDRs are
  safe to use in the `nix-daemon` `no_proxy` list.
- Reachability of the NodePort today depends on
  `mixins/nixos/ext4/k3s.ext4.nix` opening the entire **30000-32767** range to
  the firewalld `public` zone. Once nothing needs a NodePort from outside, that
  can be narrowed (separate concern).

## Decisions taken

- **Ports 21100 / 21101 / 21102 / 21109** (mixed / socks5 / http / controller).
  `clash-verge` stays exactly as it is on 1100-1109 — no collision, no change to
  `set-proxy-verge`, and the new service can run alongside it.
- **Nix-generated config + SOPS subscription URL** via `sops.templates`, rather
  than lifting the whole ConfigMap into one opaque encrypted blob. The config is
  small enough that rules and proxy-groups become reviewable.
- **No API secret on the controller.** 21109 is only reachable over LAN and
  ZeroTier, which is a personal VPN, so the current no-auth behaviour is kept.
- **A pack, not a mixin.** Most hosts run clash, so it goes in
  `packs/nixos/host/clash/` and is autowired into all five hosts. All of them
  already import sops-nix, and every host age key is in both `.sops.yaml`
  creation rules, so one shared subscription secret decrypts everywhere with no
  per-host work. Precedent: `packs/nixos/host/clash-verge.nix` is already a pack.
- **Proxy env lives in `mixins/nixos/cn/`**, not in the pack and not under
  `lan/` — it belongs to "this host is behind the CN firewall", which is
  orthogonal to both "runs clash" and "is on a LAN". `g1` is on no LAN, so
  anything under `lan/*` could never reach it. The new `cn/` mixin comes from
  [[flakes-dw38]].
- **k3s stays for now.** After this lands it hosts only minio — tracked
  separately.

## Spec

### 1. New: `packs/nixos/host/clash/default.nix`

Autowired into every host. `services.mihomo` is a singleton option, but the only
other user is `mixins/nixos/services/egress-proxy.nix`, which applies inside the
`onecli` container — a different NixOS configuration, so there is no collision.

```nix
services.mihomo = {
  enable = true;
  configFile = config.sops.templates."clash.yaml".path;
  webui = pkgs.metacubexd;   # served at http://<host>:21109/ui/
};

sops.secrets."clash-sub-url" = { sopsFile = ./secrets/clash.txt; format = "binary"; };

sops.templates."clash.yaml" = {
  restartUnits = [ "mihomo.service" ];
  content = ''
    mixed-port: 21100
    socks-port: 21101
    port: 21102
    allow-lan: true
    external-controller: 0.0.0.0:21109
    proxy-providers:
      main:
        type: http
        url: ${config.sops.placeholder."clash-sub-url"}
        path: ./providers/main.yaml
        interval: 86400
        health-check: { enable: true, interval: 600, url: ... }
    proxy-groups: ...   # ported from the live ConfigMap
    rules: ...          # ported from the live ConfigMap
  '';
};
```

- No controller `secret` — see decisions above.
- firewalld: a `clash` service covering 21100/21101/21102/21109, added to the
  `public` zone (mirroring `packs/nixos/host/clash-verge.nix`) and to the
  `incus` zone so containers can reach it.

### 2. New: `mixins/nixos/cn/proxy-env.nix`

Replaces all six sync/reset scripts. Lands in the `cn/` mixin created by
[[flakes-dw38]], which every CN host imports including `g1` (which is on no
LAN).

```nix
let
  proxy = "http://127.0.0.1:21102";
  noProxy = lib.concatStringsSep "," [
    "localhost" "127.0.0.1" "::1"
    "mirrors.tuna.tsinghua.edu.cn" "cache.nixos.org"
    "10.0.0.0/8" "10.42.0.0/16" "10.43.0.0/16" "10.100.0.0/24"
    "172.22.0.0/16" ".yjpark.org" ".incus"
  ];
in {
  systemd.services.nix-daemon.environment = {
    http_proxy = proxy; https_proxy = proxy; no_proxy = noProxy;
  };
}
```

- Same for `k3s` and `containerd`, guarded by
  `lib.mkIf config.services.k3s.enable`.
- Add `after = [ "mihomo.service" ]` to `k3s`/`containerd` — now safe, since
  mihomo is a plain unit with nothing to pull.
- `nix-daemon` needs no ordering: it reads the env at start but only uses it
  lazily at fetch time.
- Keep `10.0.0.0/8` etc. in `no_proxy` — confirmed curl honours CIDRs.

### 3. Modify `mixins/nixos/services/egress-proxy.nix`

`proxyPort = 31102` → `21102`, and update the comment: it is no longer a k3s
NodePort but a host service port.

### 4. Modify `packs/nixos/host/incus.nix`

The incus-zone firewall port `31102` → `21102`.

### 5. Modify `packs/home/common/programs/fish/aliases.nix`

Low priority — these are legacy and barely used. Since every host will run clash
on the same port, most of them collapse:

- `set-proxy-trojan` 31102 → 21102 (consider renaming to `set-proxy-clash`)
- `set-proxy-edger` → 21102; `set-proxy-edger_lan` is doubly stale (it points at
  `10.0.1.2`, and edger is now `10.0.4.2`) so deleting it beats fixing it
- `set-proxy-verge` (1102) untouched, since clash-verge is unchanged
- Worth considering deleting the per-host variants outright rather than
  renumbering them.

### 6. Delete `packs/home/host/common/scripts/nixos/proxy/`

All nine bash scripts. The directory's `default.nix` autowires everything in it
into `~/.local/bin/nixos/`, so removing the whole directory is the clean
removal.

### 7. Decommission the k3s objects

Imperative, after the host service is proven:
`kubectl -n services delete deploy/clash svc/clash cm/clash-config deploy/yacd svc/yacd ingress/yacd`

## Migration order

Getting this wrong means losing internet access on a CN-side host, so sequence
matters:

1. Extract the subscription URL (and pick an API secret) out of the live
   `clash-config` ConfigMap and into `secrets/clash.txt`.
2. Land the host mihomo pack and switch **pc first**. Verify
   `curl -x http://127.0.0.1:21102 https://example.com` and that the dashboard
   loads at `http://pc:21109/ui/` — **with the k3s clash still running**, so
   there is a fallback. Only then switch edger.
3. Land the declarative proxy env; confirm `nix-daemon` still substitutes fast
   (i.e. `no_proxy` is actually bypassing the TUNA mirror).
4. Flip `egress-proxy.nix`, `incus.nix` and the fish aliases to 21102.
5. Only then delete the k3s clash/yacd objects and the sync scripts.

## Both pc and edger are k3s clash hosts

Confirmed: edger runs clash in k3s as well, so both hosts get the same migration
and the same decommission step. The service is an autowired pack, so a single
`nixos-rebuild` on each host picks it up and the k3s teardown is identical.

Per-host unknowns to check while implementing:

- whether edger's clash Deployment/Service uses the same ports and the same
  `clash-config` ConfigMap shape as pc's
- whether edger also runs a `yacd` Deployment + Ingress to drop
- whether edger's k3s hosts anything else (pc's only other workload is minio,
  tracked in [[flakes-jspq]])

## Corrections to the original spec

Two things in this bean's spec were wrong, found by reading the live ConfigMap:

- **There are two subscription providers**, `shadowsocks` and `okcloud`, not
  one. Each has its own URL, so there are two secrets. Their `health-check`
  URLs are both `http://www.gstatic.com/generate_204` — not secret, so they
  stay in the Nix source.
- **The rules do use `GEOIP,CN`.** The spec said to keep the config free of
  GEOIP/GEOSITE rules, because matching them makes mihomo download geodata
  which it cannot do before the proxy works. The constraint was real but the
  conclusion was not: the rule has to stay, so the geodata ships from the store
  instead.

## Geodata, and the bootstrap problem it was hiding

The k3s pod's working directory held `geoip.dat` (19M), `geoip.metadb` (9M) and
`geosite.dat` (4M), all downloaded — into an **ephemeral** filesystem with no
PVC, so a pod restart re-fetched ~32M through the very proxy it was starting up
to provide.

`GEOIP,CN` is the only geo rule, so `v2ray-geoip`'s
`geoip-only-cn-private.dat` subset suffices at **260K**, against 23M for the
full `geoip.dat` or 8.1M for a dbip mmdb. Installed from the store by an
`ExecStartPre`, with `geo-auto-update: false`, so nothing is fetched at runtime
and the data tracks nixpkgs.

Verified against mihomo 1.19.23: `Load GeoIP rule: cn` →
`Finished initial GeoIP rule cn => DIRECT, records: 16482`, no download
attempted. Routing then checked both ways through mihomo's HTTP proxy —
`www.baidu.com` (CN) returned 200 via DIRECT, `example.com` matched `MATCH` and
went to the upstream proxy.

## Summary of Changes

### `packs/nixos/host/clash/default.nix` (new)

Autowired into every host.

- `services.mihomo` on 21100 (mixed) / 21101 (socks) / 21102 (http) / 21109
  (controller), leaving clash-verge's 1100-1109 untouched.
- `webui = pkgs.metacubexd` — dashboard served from the controller port, same
  origin as the API, so no ingress and no mixed-content problem. metacubexd
  ships `index.html` at its package root so the path works as-is. (`yacd` is
  not in nixpkgs.)
- Config rendered via `sops.templates."clash.yaml"` with the provider URLs from
  `sops.placeholder`, and `restartUnits = [ "mihomo.service" ]`. Providers,
  proxy-groups and rules are generated from one `providers` attrset and one
  rules list.
- Rules carried over verbatim, including the absence of `no-resolve` on the
  IP-CIDR rules, so matching behaviour is unchanged.
- Exposes read-only `clash.httpPort` / `clash.proxyUrl` so host-side consumers
  do not repeat the port number.
- firewalld: a `clash` service (all four ports) in the `public` zone, plus only
  21102 in the `incus` zone, so containers get the proxy and nothing else.

### `packs/nixos/host/clash/secrets/clash.yaml` (new, SOPS)

The two provider URLs, extracted from the live ConfigMap, encrypted to all six
host age keys. Decrypt round-trip checked.

### `mixins/nixos/cn/proxy-env.nix` (new)

`http_proxy`/`https_proxy`/`all_proxy`/`no_proxy` on `nix-daemon`, and on `k3s`
and `containerd` behind `lib.mkIf` on their enable flags, the latter two ordered
after `mihomo.service`. Lowercase names only: curl reads those, Nix propagates
exactly those into fixed-output derivation builders via `impureEnvVars`, and Go
falls back to lowercase. `NIX_CURL_FLAGS` dropped — modern Nix ignores it.

`no_proxy` keeps both substituters direct. Note `containerd` is not a separate
unit on pc (`virtualisation.containerd.enable = false`; k3s embeds its own), so
that branch is inert there — the old `sync-proxy_containerd` script was
targeting something that no longer exists.

### Other

- `mixins/nixos/services/egress-proxy.nix`: `proxyPort` 31102 → 21102, with a
  note on why it stays hardcoded rather than reading `config.clash.httpPort`
  (the container's configuration does not import the host pack).
- `packs/nixos/host/incus.nix`: the 31102 hole is reverted — the clash pack owns
  that rule now, so the port number lives in one place.
- `aliases.nix`: `set-proxy-trojan` → `set-proxy-clash` on 21102, and
  `set-proxy-edger` uses `edger.yjpark.zerotier` instead of a raw IP.
- Deleted `packs/home/host/common/scripts/nixos/proxy/` (nine scripts).

## Verification

- All five host configs plus the `onecli` container dry-run build.
- The rendered config passes `mihomo -t` with placeholders substituted,
  including the GeoIP load.
- The `ExecStartPre` was checked against the real sandbox via `systemd-run` with
  `DynamicUser=yes`, `StateDirectory=`, `ProtectSystem=strict` and
  `PrivateUsers=yes` — the file lands in the state directory.
- `onecli`'s generated config points at `10.100.0.1:21102`.
- firewalld: `clash` in `public`; `incus` zone ports are 21102 plus the
  pre-existing 5354 pair.

Not verified, because it needs a switch: that mihomo actually starts, fetches
the subscriptions, and serves the dashboard.

## Migration hazard: stale /run overrides

`/run/systemd/system/nix-daemon.service.d/override.conf` exists on pc right
now, written by the old `sync-proxy_nix-daemon`, pointing at `localhost:31102`.
**`/run` drop-ins outrank `/etc` ones**, so it will shadow the new declarative
environment until removed or the host reboots — and it names a port that stops
existing once the k3s clash is deleted.

Clear it during the switch, before deleting the k3s objects:

```
sudo rm -rf /run/systemd/system/{nix-daemon,k3s,containerd}.service.d
sudo systemctl daemon-reload
sudo systemctl restart nix-daemon
```

Then check `systemctl cat nix-daemon | grep proxy` shows only 21102.
`reset-proxy_nix-daemon` used to do this and is being deleted, so the step must
happen before or during the switch.

## Tasks

- [ ] Inspect edger's k3s: confirm its clash Deployment/Service/ConfigMap shape, whether it has yacd, and what else runs there
- [x] Extract the subscription URLs (two providers) into `packs/nixos/host/clash/secrets/clash.yaml` (SOPS)
- [x] Port `proxy-groups` and `rules` from the ConfigMap into the Nix-authored config
- [x] Create `packs/nixos/host/clash/default.nix` (services.mihomo + sops.templates + firewalld, ports 21100/21101/21102/21109, metacubexd webui, no controller secret)
- [x] Ship GeoIP data from the store instead of letting mihomo download it
- [ ] Switch pc, then verify the proxy and the dashboard work while the k3s clash is still running
- [ ] Clear the stale `/run/systemd/system/*.service.d` drop-ins (see Migration hazard)
- [x] Create `mixins/nixos/cn/proxy-env.nix` for nix-daemon / k3s / containerd, with `after = mihomo.service` on the latter two
- [ ] Verify `no_proxy` keeps substituter traffic direct (compare download speed before/after)
- [x] Flip `egress-proxy.nix` proxyPort to 21102; the `incus.nix` hole is reverted and now owned by the clash pack
- [x] Update the `set-proxy-*` fish aliases
- [x] Delete `packs/home/host/common/scripts/nixos/proxy/`
- [ ] Delete the k3s `clash` and `yacd` objects on **both** pc and edger
- [ ] Roll out to the remaining hosts (a13, g1, p2) and confirm each one's proxy works
- [ ] Re-verify the onecli → clash egress chain after the port flip (see [[flakes-i9ao]])

## Coupling with flakes-i9ao

`flakes-i9ao` just landed the onecli egress chain pointing at `10.100.0.1:31102`
and still has unverified in-situ checks. Either verify it on edger first and
then renumber, or do both in one deploy — but do not renumber while the original
chain is still unproven.
