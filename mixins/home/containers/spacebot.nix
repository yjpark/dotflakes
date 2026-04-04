{flake, pkgs, ...}: let
  inherit (flake) inputs;
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
  ];

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
