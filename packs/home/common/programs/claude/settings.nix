{
  config,
  ...
}: {
  home.sessionVariables = {
    CLAUDE_CODE_NEW_INIT = "1";
    CLAUDE_CODE_NO_FLICKER = "1";
    #CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN = "1";
  };

  programs.claude-code = {
    enable = true;

    # Host health, metrics and journald logs for the always-on hosts, served by
    # the monitoring hubs (mixins/nixos/services/monitoring/mcp.nix).
    mcpServers = {
      victoriametrics = {
        type = "http";
        url = "http://${config.me.monitoringHub}:8430/mcp";
      };
      victorialogs = {
        type = "http";
        url = "http://${config.me.monitoringHub}:9430/mcp";
      };

      # Cloudflare's hosted MCP server (Workers, R2, KV, D1, DNS, ...). OAuth on
      # first use; from a container the callback comes back through
      # packs/nixos/container/mcp-oauth-bridge.nix and the host-side ssh forward
      # (packs/home/host/common/mcp-oauth-forward.nix).
      cloudflare = {
        type = "http";
        url = "https://mcp.cloudflare.com/mcp";
      };
    };
  };
}
