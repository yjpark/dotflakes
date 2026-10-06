---
# flakes-dw38
title: 'Restructure lan mixins: per-site LANs plus separate cn concerns'
status: todo
type: task
priority: normal
created_at: 2026-10-05T14:33:09Z
updated_at: 2026-10-06T03:19:44Z
parent: flakes-qbvb
---

The `lan/{cn,my}` split no longer matches reality. All hosts are in CN, but
there are now **three CN sites** on different subnets, and site membership has
changed. Restructure so per-site LAN facts and CN-wide facts are separate
concerns.

Prerequisite for [[flakes-k0sx]], which needs a home for the declarative proxy
environment that also covers `g1`.

## Why the current layout fails

`mixins/nixos/lan/cn` conflates concerns with different scopes:

| concern | real scope | currently in |
|---|---|---|
| firewall zone sources | **per-site** (was a blanket `10.0.0.0/16`) | `lan/{cn,my}/firewall.nix`, byte-identical |
| bare short hostnames | **per-site** | `lan/{cn,my}/hosts.nix` |
| TUNA substituter | every CN host, LAN or not | `lan/cn/mirrors.nix` |
| proxy env (new) | every CN host, LAN or not | — |

Nothing under `lan/*` can reach `g1`, which imports no `lan` mixin at all — that
is what rules out putting the proxy env there.

## Cross-site naming is already solved

`packs/nixos/host/zerotier/zerotier.nix` is autowired into every host and maps
each machine to `<name>.yjpark.zerotier` → `172.22.1.x`. Those are flat,
site-independent, and route from anywhere. So per-site `hosts.nix` files carry
only their **own** subnet and cross-site access uses the ZeroTier names — a bare
name then never resolves to an address that cannot route.

ZeroTier addresses are **not** changing. edger stays `172.22.1.2` there while its
LAN address becomes `10.0.4.2`.

## Site inventory

Site names are the directory names; the leading digit matches the third octet.

### Site `102` — `10.0.1.0/24`

```
10.0.1.1    router
10.0.1.9    pc desktop
10.0.1.10   mbp-2012
10.0.1.11   mbp
```

`pc` is **10.0.1.9**, confirmed against the live host (`eno1 10.0.1.9/24`,
default route via `10.0.1.1`) and consistent with its ZeroTier `172.22.1.9`.
`10.0.1.2` was edger's address at the *old* site, not pc's.

### Site `401` — `10.0.4.0/24`

```
10.0.4.1    router
10.0.4.2    edger
10.0.4.3    imac
10.0.4.5    p2 gpd-p2
10.0.4.6    a13 alienware-13
10.0.4.12   p2_wifi gpd-p2_wifi
10.0.4.13   a13_wifi alienware-13_wifi
```

Host parts are preserved from the old `10.0.1.x` numbering; only the third octet
changes.

### Site `708` — `10.0.7.0/24`

```
10.0.7.1    router
10.0.7.8    g1 hp-g1
```

## Target layout

```
mixins/nixos/lan/
  102/  { firewall.nix (10.0.1.0/24), hosts.nix }
  401/  { firewall.nix (10.0.4.0/24), hosts.nix }
  708/  { firewall.nix (10.0.7.0/24), hosts.nix }

mixins/nixos/cn/
  mirrors.nix     # moved from lan/cn/mirrors.nix
  proxy-env.nix   # new, see flakes-k0sx
```

Each host imports `lan/<site>` **plus** `cn`:

| host  | site | imports |
|-------|------|---------|
| pc    | 102  | `lan/102` + `cn` |
| edger | 401  | `lan/401` + `cn` |
| p2    | 401  | `lan/401` + `cn` |
| a13   | 401  | `lan/401` + `cn` |
| g1    | 708  | `lan/708` + `cn` |

`firewall.nix` is split per site rather than hoisted, narrowing
`services.firewalld.zones.lan.sources` from `10.0.0.0/16` to each site's own
`/24`. Strictly tighter, and safe because cross-site traffic arrives over
ZeroTier (`172.22.0.0/16`), which `packs/nixos/container/firewall.nix` and the
host configs already place in the `trusted` zone.

Autowire note: `lan/cn/default.nix` is `wireImports ./.` (non-recursive). Each
new site directory needs its own `default.nix` doing the same, and `lan/` itself
must **not** get one, or it would pull every site into every host.

## Live bug this uncovered

`nixos/hosts/a13/samba.nix:21` has:

```nix
"hosts allow" = "10.0.1. 127.0.0.1 localhost";
"hosts deny" = "0.0.0.0/0";
```

a13 is now at site `401` (`10.0.4.x`), so **every client on a13's own LAN was
denied** — its samba shares were unreachable, and ZeroTier (`172.22.`) was not
allowed either so cross-site access failed too.

**Fixed** ahead of this restructure: now `10.0.4. 172.22. 127.0.0.1 localhost`,
verified by evaluating `nixosConfigurations.a13`. The prefix is still hardcoded,
so deriving it from `mixins/nixos/lan/401` once that exists remains a task.

## Entries being dropped

- **`edger_wifi`** — edger is not on wifi any more. Remove `10.0.1.127
  edger_wifi` (`lan/my/hosts.nix`) and `172.22.1.14
  edger_wifi.yjpark.zerotier` (`zerotier.nix`).
- **`x1` / `thinkpad-x1`** — still in use and may appear at any site, but it is a
  Windows laptop, so it is deliberately not managed here for now. Remove from
  the hosts files and from `zerotier.nix` (`172.22.1.7`). This is "unmanaged",
  not "gone".
- **stale `10.0.1.8 g1 hp-g1`** in `lan/cn/hosts.nix` — superseded by site 708.

## Other changes

- `edger` and `p2` newly pick up the TUNA substituter, since `lan/my` had no
  `mirrors.nix`. Confirm that is wanted.
- `packs/home/common/programs/fish/aliases.nix:13` —
  `set-proxy-edger_lan = "set-proxy 10.0.1.2 31102"` is wrong on both address
  and port. Legacy, so delete rather than fix.
- Verified there is no cross-host LAN service dependency to worry about:
  `mixins/nixos/services/nix-serve.nix` on edger has `openFirewall` but no host
  declares it as a substituter, and cross-host incus goes to
  `*.yjpark.org:8443` over ZeroTier.

## Tasks

- [ ] Create `mixins/nixos/lan/{102,401,708}/` each with `default.nix`, `firewall.nix` (own `/24`) and `hosts.nix` (own subnet only)
- [ ] Create `mixins/nixos/cn/` and move `mirrors.nix` into it
- [ ] Update all five hosts' `imports.nix` to `lan/<site>` + `cn`
- [ ] Drop `edger_wifi` and `x1` from `hosts.nix` files and from `packs/nixos/host/zerotier/zerotier.nix`
- [x] Fix `nixos/hosts/a13/samba.nix` — allow `10.0.4.` and `172.22.` (done ahead of the restructure; still a hardcoded prefix)
- [ ] Derive a13 samba `hosts allow` from `mixins/nixos/lan/401` instead of the hardcoded prefix
- [ ] Delete `mixins/nixos/lan/my/` and `mixins/nixos/lan/cn/`
- [ ] Delete the legacy `set-proxy-edger_lan` alias
- [ ] Confirm edger/p2 should get the TUNA substituter
- [ ] Build all five host configs and diff `/etc/hosts` + firewalld zones against the current generations
- [ ] After switching, verify same-site LAN access still works on each host (the firewall narrowed from /16 to /24)
