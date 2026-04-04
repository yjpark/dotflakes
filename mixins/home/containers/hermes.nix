{flake, pkgs, ...}: let
  inherit (flake) inputs;
  hermes-agent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # The hermes-agent package is a wrapper; extract the underlying Python env
  hermes-agent-env = pkgs.runCommand "hermes-agent-env" {} ''
    env=$(grep -oP '/nix/store/[^ "]+hermes-agent-env' ${hermes-agent}/bin/hermes | head -1)
    ln -s "$env" $out
  '';
  hermes-webui = pkgs.writeShellApplication {
    name = "hermes-webui";
    text = ''
      export HERMES_WEBUI_AGENT_DIR="''${HERMES_WEBUI_AGENT_DIR:-${inputs.hermes-agent}}"
      export HERMES_WEBUI_PYTHON="''${HERMES_WEBUI_PYTHON:-${hermes-agent-env}/bin/python}"
      cd ${inputs.hermes-webui}
      exec ${hermes-agent-env}/bin/python server.py "$@"
    '';
  };
  hermes-gateway-status = pkgs.writeShellScriptBin "hermes-gateway-status" "systemctl --user status hermes-gateway";
  hermes-gateway-restart = pkgs.writeShellScriptBin "hermes-gateway-restart" ''
    systemctl --user restart hermes-gateway
    ${hermes-gateway-status}/bin/hermes-gateway-status
  '';
  hermes-gateway-journal = pkgs.writeShellScriptBin "hermes-gateway-journal" ''journalctl --user -u hermes-gateway -f "$@"'';
  hermes-webui-status = pkgs.writeShellScriptBin "hermes-webui-status" "systemctl --user status hermes-webui";
  hermes-webui-restart = pkgs.writeShellScriptBin "hermes-webui-restart" ''
    systemctl --user restart hermes-webui
    ${hermes-webui-status}/bin/hermes-webui-status
  '';
  hermes-webui-journal = pkgs.writeShellScriptBin "hermes-webui-journal" ''journalctl --user -u hermes-webui -f "$@"'';
in {
  home.packages = [
    hermes-agent
    hermes-webui
    hermes-gateway-restart
    hermes-gateway-status
    hermes-gateway-journal
    hermes-webui-restart
    hermes-webui-status
    hermes-webui-journal
  ];

  systemd.user.services.hermes-webui = {
    Unit = {
      Description = "Hermes Web UI";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${hermes-webui}/bin/hermes-webui";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "HERMES_WEBUI_HOST=0.0.0.0"
      ];
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.hermes-gateway = {
    Unit = {
      Description = "Hermes Agent Gateway";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${hermes-agent}/bin/hermes gateway run --replace";
      WorkingDirectory = "%h/.hermes";
      EnvironmentFile = "%h/.hermes/.env";
      Environment = [
        "HERMES_HOME=%h/.hermes"
      ];
      Restart = "on-failure";
      RestartSec = 30;
      KillMode = "mixed";
      KillSignal = "SIGTERM";
      TimeoutStopSec = 60;
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
