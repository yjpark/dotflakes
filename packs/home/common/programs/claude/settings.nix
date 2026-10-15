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
    };
  };
}
