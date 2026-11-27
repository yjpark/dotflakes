# kudo-node as a user service, dialing this host's hub on the incus bridge.
# Used by the incus hosts (pc, edger) and their yolo containers.
{ config, flake, lib, pkgs, ... }:
let
  cfg = config.services.kudo-node;
  kudo-mcp = pkgs.writeShellApplication {
    name = "kudo-mcp";
    runtimeInputs = [ pkgs.coreutils pkgs.gawk ];
    text = ''
      if [ -z "''${KUDO_SESSION_ID:-}" ]; then
        parent_start=$(awk '{print $22}' "/proc/$PPID/stat")
        KUDO_SESSION_ID=$(printf '%s' "$PPID:$parent_start:$PWD" | sha256sum | cut -d ' ' -f1)
        export KUDO_SESSION_ID
      fi
      set -a
      for env_file in "$HOME/.config/kudo/hub.env" /run/secrets/kudo-hub-user.env; do
        if [ -r "$env_file" ]; then
          # shellcheck disable=SC1090
          . "$env_file"
        fi
      done
      set +a
      export KUDO_HUB_ADDR="''${KUDO_HUB_ADDR:-${cfg.hubAddr}}"
      ${lib.optionalString (cfg.privateKeyFile != null) ''
        export HUB_PRIVATE_KEY_FILE="''${HUB_PRIVATE_KEY_FILE:-${cfg.privateKeyFile}}"
      ''}
      exec ${cfg.package}/bin/kudo-shim "$@"
    '';
  };
in
{
  imports = [ flake.inputs.kudo.homeModules.kudo-node ];

  home.packages = lib.mkIf cfg.enable [ kudo-mcp ];
  programs.claude-code.mcpServers = lib.mkIf cfg.enable {
    kudo = {
      command = "${kudo-mcp}/bin/kudo-mcp";
      args = [ ];
      env.KUDO_AGENT_HARNESS = "claude";
    };
  };

  services.kudo-node = {
    enable = true;
    hubAddr = "10.100.0.1:15400";
    privateKeyFile =
      if config.home.username == "yj"
      then "${config.home.homeDirectory}/.config/kudo/hub.key"
      else "/run/secrets/kudo-hub-user.key";
    # Every node runs governed: these argvs run without asking; anything else
    # waits for a verdict in the console (30 minutes, then denied).
    environment.KUDO_NODE_RULES = "${./kudo-node-rules.styx}";
  };

  systemd.user.services.kudo-node.Service.EnvironmentFile = [
    "-%h/.config/kudo/hub.env"
    "-/run/secrets/kudo-hub-user.env"
  ];
}
