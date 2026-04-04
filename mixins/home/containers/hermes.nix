{flake, pkgs, ...}: let
  inherit (flake) inputs;
  hermes-agent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  python = pkgs.python3.withPackages (ps: [ ps.pyyaml ]);
  hermes-webui = pkgs.writeShellApplication {
    name = "hermes-webui";
    runtimeInputs = [ python ];
    text = ''
      export HERMES_WEBUI_AGENT_DIR="''${HERMES_WEBUI_AGENT_DIR:-${inputs.hermes-agent}}"
      export HERMES_WEBUI_PYTHON="''${HERMES_WEBUI_PYTHON:-${python}/bin/python3}"
      cd ${inputs.hermes-webui}
      exec python server.py "$@"
    '';
  };
in {
  home.packages = [
    hermes-agent
    hermes-webui
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
