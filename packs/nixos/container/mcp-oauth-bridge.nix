{ pkgs, lib, ... }:
let
  # MCP OAuth callback port, pinned so a host-side bridge can forward the
  # OAuth callback into the container. See bean flakes-wq6s.
  #
  # Background: when Claude Code (running in this container) performs MCP OAuth,
  # the browser opens on a *different* machine (the host desktop, or Windows via
  # WSL/SSH). Claude Code's callback listener binds 127.0.0.1 only and the
  # redirect host is hardcoded to `http://localhost:<port>/callback`, so the
  # callback must be relayed back in. `MCP_OAUTH_CALLBACK_PORT` wins
  # unconditionally in the CC binary (no availability check), so pinning it to a
  # known port is mandatory for a bridge.
  #
  # The bridge itself is emitted by the ingress config generator
  # (packs/nixos/container/ingress-scripts/generate-ingress-config.bash), which
  # writes a Caddy site binding the container's eth0 IP on this port and reverse
  # proxying to 127.0.0.1:<port> where CC listens. A socket bound to `lo` won't
  # serve a connection arriving on eth0, hence the bridge. We bind the container
  # IP only (not 0.0.0.0) so CC's own 127.0.0.1:<port> listener stays free.
  #
  # The remaining hops (delivering the callback + opening the browser on the
  # host desktop / Windows-WSL) are tracked in flakes-mqe9 and its children.
  callbackPort = "3118";

  # Phase A browser-open (flakes-vzo1): surface the authorize URL on the human's
  # terminal (OSC 8 link + OSC 52 clipboard + bell) instead of trying to open a
  # browser in a headless container. Works over any access path, no detection.
  browserOpen = pkgs.writeShellApplication {
    name = "browser-open";
    runtimeInputs = with pkgs; [ coreutils ];
    text = builtins.readFile ./mcp-scripts/browser-open.bash;
  };

  # xdg-open shim -> browser-open. Tools (incl. Claude Code) often call xdg-open
  # directly rather than honouring $BROWSER; hiPrio wins any collision with a
  # real xdg-utils in the container closure.
  xdgOpenShim = lib.hiPrio (pkgs.writeShellScriptBin "xdg-open" ''
    exec ${browserOpen}/bin/browser-open "$@"
  '');
in
{
  # 1. Pin Claude Code's MCP OAuth callback port (login-shell env).
  environment.variables.MCP_OAUTH_CALLBACK_PORT = callbackPort;

  # 2. Expose the same port to the ingress config generator, which runs as the
  #    ingress-sync systemd service and emits the Caddy bridge site.
  systemd.services.ingress-sync.serviceConfig.Environment =
    [ "MCP_OAUTH_CALLBACK_PORT=${callbackPort}" ];

  # 3. Route browser-open through the terminal (Phase A).
  environment.variables.BROWSER = "${browserOpen}/bin/browser-open";
  environment.systemPackages = [ browserOpen xdgOpenShim ];
}
