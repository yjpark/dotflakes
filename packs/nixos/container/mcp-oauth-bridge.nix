{ ... }:
let
  # MCP OAuth callback port, pinned so a host-side bridge can forward the
  # OAuth callback into the container. See bean flakes-wq6s.
  #
  # Background: when Claude Code (running in this container) performs MCP OAuth,
  # the browser opens on a *different* host (e.g. the Mac). Claude Code's
  # callback listener binds 127.0.0.1 only and the redirect host is hardcoded to
  # `http://localhost:<port>/callback`, so the callback must be relayed back in.
  # `MCP_OAUTH_CALLBACK_PORT` wins unconditionally in the CC binary (no
  # availability check), so pinning it to a known port is mandatory for a bridge.
  #
  # The bridge itself is emitted by the ingress config generator
  # (packs/nixos/container/ingress-scripts/generate-ingress-config.bash), which
  # writes a Caddy site binding the container's eth0 IP on this port and reverse
  # proxying to 127.0.0.1:<port> where CC listens. A socket bound to `lo` won't
  # serve a connection arriving on eth0, hence the bridge. We bind the container
  # IP only (not 0.0.0.0) so CC's own 127.0.0.1:<port> listener stays free.
  #
  # The remaining hop (Mac browser -> container IP:<port>) is a host-side
  # launchd socat forwarder over the VM route; that lives outside this repo.
  callbackPort = "3118";
in
{
  # 1. Pin Claude Code's MCP OAuth callback port (login-shell env).
  environment.variables.MCP_OAUTH_CALLBACK_PORT = callbackPort;

  # 2. Expose the same port to the ingress config generator, which runs as the
  #    ingress-sync systemd service and emits the Caddy bridge site.
  systemd.services.ingress-sync.serviceConfig.Environment =
    [ "MCP_OAUTH_CALLBACK_PORT=${callbackPort}" ];
}
