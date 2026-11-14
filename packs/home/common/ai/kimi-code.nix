{ config
, flake
, lib
, pkgs
, ...
}:
let
  kimi-code = flake.inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system};
  workspaceHome = "${config.home.homeDirectory}/.gemini/extensions/google-workspace";
  workspaceReadOnly = "docs.write:off,drive.write:off,calendar.write:off,chat.write:off,gmail.write:off";
  workspaceLibraryPath = lib.makeLibraryPath [ pkgs.libsecret pkgs.glib pkgs.stdenv.cc.cc.lib ];
  google-workspace-auth = pkgs.writeShellScriptBin "google-workspace-auth" ''
    export LD_LIBRARY_PATH="${workspaceLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    export WORKSPACE_FEATURE_OVERRIDES="${workspaceReadOnly}"
    exec ${pkgs.nodejs}/bin/node ${workspaceHome}/scripts/auth-utils.js "$@"
  '';
in
{
  options.kimiCode.defaultPermissionMode = lib.mkOption {
    type = lib.types.enum [ "manual" "yolo" "auto" ];
    default = "yolo";
    description = "Default permission mode for new Kimi Code sessions";
  };

  config = {
    # claude-code itself is installed by programs.claude-code (as a wrapper once
    # mcpServers is set), so it is not listed again here.
    home.packages = [
      kimi-code.default
      google-workspace-auth
    ];

    # Host monitoring, Cloudflare's hosted API, and read-only Google Workspace.
    home.file.".kimi-code/mcp.json".text = builtins.toJSON {
      mcpServers = {
        victoriametrics = {
          type = "http";
          url = "http://${config.me.monitoringHub}:8430/mcp";
        };
        victorialogs = {
          type = "http";
          url = "http://${config.me.monitoringHub}:9430/mcp";
        };
        cloudflare = {
          type = "http";
          url = "https://mcp.cloudflare.com/mcp";
        };
        google-workspace = {
          command = "${pkgs.nodejs}/bin/node";
          args = [ "${workspaceHome}/workspace-server/dist/index.js" ];
          cwd = workspaceHome;
          env = {
            LD_LIBRARY_PATH = workspaceLibraryPath;
            WORKSPACE_FEATURE_OVERRIDES = workspaceReadOnly;
          };
        };
      };
    };

    home.activation.kimiCodeDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="${lib.makeBinPath [ pkgs.coreutils pkgs.gawk ]}:$PATH"
      _kimi_config="${config.home.homeDirectory}/.kimi-code/config.toml"
      _kimi_candidate="$_kimi_config.new"
      if [ ! -f "$_kimi_config" ]; then
        run mkdir -p "$(dirname "$_kimi_config")"
        run touch "$_kimi_config"
      fi
      run cp -p "$_kimi_config" "$_kimi_candidate"
      run awk -v model='default_model = "kimi-code/k3.1-pro"' \
        -v permission='default_permission_mode = "${config.kimiCode.defaultPermissionMode}"' '
        BEGIN {
          print model
          print permission
        }
        /^[[:space:]]*\[/ { in_tables = 1 }
        !in_tables && /^[[:space:]]*default_model[[:space:]]*=/ { next }
        !in_tables && /^[[:space:]]*default_permission_mode[[:space:]]*=/ { next }
        { print }
      ' "$_kimi_config" > "$_kimi_candidate"
      ${kimi-code.default}/bin/kimi doctor config "$_kimi_candidate"
      if ! cmp -s "$_kimi_config" "$_kimi_candidate"; then
        _kimi_backup="$_kimi_config.$(date +%Y%m%d-%H%M%S).bak"
        run cp "$_kimi_config" "$_kimi_backup"
        run mv "$_kimi_candidate" "$_kimi_config"
      else
        run rm "$_kimi_candidate"
      fi
    '';
  };
}
