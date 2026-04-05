{flake, pkgs, ...}: let
  inherit (flake) inputs;
  llm-agents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  spacebot = inputs.spacebot.packages.${pkgs.stdenv.hostPlatform.system}.default;
  spacebot-status = pkgs.writeShellScriptBin "spacebot-status" "systemctl --user status spacebot";
  spacebot-restart = pkgs.writeShellScriptBin "spacebot-restart" ''
    systemctl --user restart spacebot
    ${spacebot-status}/bin/spacebot-status
  '';
  spacebot-journal = pkgs.writeShellScriptBin "spacebot-journal" ''journalctl --user -u spacebot -f "$@"'';
in {
  home.packages = [
    spacebot
    spacebot-restart
    spacebot-status
    spacebot-journal
    llm-agents.opencode
    llm-agents.claude-code
  ];

  # OpenCode with claude-code-plugin: delegates to claude-code CLI for AI completions.
  # Plugin source: github:unixfox/opencode-claude-code-plugin (in flake inputs)
  # Placed at ~/.config/opencode/plugins/claude-code so OpenCode can load it.
  xdg.configFile."opencode/plugins/claude-code".source =
    inputs.opencode-claude-code-plugin;

  systemd.user.services.spacebot = {
    Unit = {
      Description = "Spacebot AI Agent";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${spacebot}/bin/spacebot start --foreground";
      WorkingDirectory = "%h/.spacebot";
      EnvironmentFile = "%h/.spacebot/.env";
      Environment = [
        "SPACEBOT_DIR=%h/.spacebot"
        "SPACEBOT_DEPLOYMENT=nixos"
      ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
