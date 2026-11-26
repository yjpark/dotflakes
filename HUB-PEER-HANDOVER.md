# Hub reverse-peer deployment and test handover

## Current state

The hub now supports authenticated reverse peer registration. One outbound
connection carries `ConsumerApi` lanes in both directions, so a private hub can
dial the public hub and immediately become reachable through it.

Relevant revisions:

- Hub implementation and lifecycle fixes: `3dadb9e` (plus documentation commit
  `0f8aec2` in the hub repository).
- Kudo dependency pin: `d403c91`.
- Kudo intake documentation: `9706a54`.
- Flakes hub input update: `898ab1b`; `flake.lock` pins hub `3dadb9e`.
- Flakes must also pin Kudo `9706a54` or newer; older Kudo inputs have an
  incompatible hub protocol.

The full hub and Kudo test suites, zero-warning clippy, Kudo `nix flake check`,
and the `hub.yjpark.org` NixOS build passed. Independent lifecycle review was
completed and its findings were fixed and re-reviewed. No deployment or live
public WSS test has been performed yet.

There are existing staged flakes changes belonging to YJ's pc/edger/public-hub
topology work. Preserve them; do not reset or commit them as part of a lockfile
or handover-only change.

## Intended topology

`mixins/nixos/services/kudo-hub.nix` configures both private hubs to dial the
public hub through their local Caddy listener on `127.0.0.1:15401`. Caddy uses
its Go TLS stack for the public WSS hop. The public hub intentionally has no
peer entries. This is now sufficient:

```text
pc    --- WS ---> local Caddy --- authenticated WSS ---> hub.yjpark.org:443
edger --- WS ---> local Caddy --- authenticated WSS ---> hub.yjpark.org:443
```

Each private hub authenticates and registers its `services.hub.name` through
`PeerIngress`. The public hub opens a reverse `ConsumerApi` lane over the same
connection.

Expected names:

- On the public hub: `pc::<node-id>` and `edger::<node-id>`.
- On pc/edger: public nodes appear as `hub::<node-id>`.
- The existing pc/edger ZeroTier peering remains independent.
- Routing is one hop; do not try to route through two hubs.

The public hub needs no return address and no Cloudflare Access service token
for these reverse calls. `HUB_AUTH_TOKEN` must match on the public hub, private
hubs, nodes, and sending shim. Keep the token and all SOPS contents out of logs,
commits, and this document.

## Deploy

Build before switching:

```sh
nix build '.#nixosConfigurations."hub.yjpark.org".config.system.build.toplevel' --no-link
```

Deploy the public hub first so it offers `PeerIngress`:

```sh
mise run update-hub
```

Then deploy pc and edger on their own machines:

```sh
mise run _switch-host
```

Existing older forward-only peers remain compatible, so a rolling deployment
should not break existing forward paths. Reverse discovery requires both ends
of a connection to support `PeerIngress`.

Check services after deployment:

```sh
systemctl status hub --no-pager
journalctl -u hub -n 100 --no-pager
systemctl --user status kudo-node --no-pager
```

Do not print environment files or secrets while inspecting failures.

## Verify reverse discovery

Configure an agent's existing `kudo-shim` MCP server with:

```sh
# On pc or edger:
KUDO_HUB_ADDR=ws://127.0.0.1:15401
# Elsewhere, use wss://hub.yjpark.org:443 instead.
HUB_AUTH_TOKEN=<shared-token>
KUDO_INTAKE_MACHINE=work
```

Use the MCP `nodes` tool. Once pc and edger have connected, the topology should
include their nodes as `pc::<node-id>` and `edger::<node-id>`. No
`services.hub.peers` entry should be added on the public hub.

Also verify that a routed read/call reaches a node under each private hub's
name. A successful topology read alone does not prove the reverse routing lane.

## Configure and test Kudo intake

The intake connector is not enabled merely by peering the hubs. On the home
node, prepare a dedicated clean `main` checkout and configure:

```sh
KUDO_INTAKE_TARGETS=kudo=/home/yj/intake/kudo
```

The checkout must contain a Kinora `inbox` root and must not be dirty or
detached. The receiver commits arrivals locally; it does not push them.

From the remote MCP session, call `send_note` with:

- `node`: `edger::<node-id>` (replace this with the actual registered node id).
- `target`: `kudo`.
- `title`: `Reverse peer smoke test`.
- `body`: a short text-only note, with no code or employer-specific content.
- `attestation`: `true`, only after reviewing the body.
- `id`: a fixed test id such as `reverse-peer-smoke-1`.

Expected result: `delivered kino://…`. Retry the exact same note id and expect
`duplicate kino://…`. Use `intake_list` with the same node/target and a suitable
RFC 3339 `since` timestamp to confirm the arrival and `unreviewed=true`.

Delivery is online-only. `unavailable` means nothing was accepted; retry later
with the same id. `refused` means the receiver rejected the note and supplies
the reason.

## Troubleshooting

- **Only `hub::<node>` is visible:** the private hub may still run an older
  binary, reverse registration may have failed, or `HUB_NAME` may be wrong.
  Confirm the deployed lock/input resolves to hub `3dadb9e`.
- **Authentication errors:** check token availability and equality on every
  role without printing it. Reverse `ConsumerApi` authentication is required
  as well as `PeerIngress` authentication.
- **WSS connection fails:** check Caddy and the public WebSocket listener on
  `127.0.0.1:15401`; the public endpoint is `wss://hub.yjpark.org:443`.
- **Topology appears but calls fail:** verify the target has exactly one peer
  qualifier, such as `edger::yolo`, and that the node is connected to edger's
  local hub.
- **Intake is unavailable:** check `KUDO_INTAKE_TARGETS`, the dedicated
  checkout's cleanliness/branch, and the receiving `kudo-node` service.
