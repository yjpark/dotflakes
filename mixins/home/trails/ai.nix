{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "install-googleworkspace-cli"  ''
      #!/usr/bin/env bash

      npm install -g @googleworkspace/cli
    '')

    (writeShellScriptBin "install-claude-trace"  ''
      #!/usr/bin/env bash

      npm install -g @mariozechner/claude-trace
    '')

    (writeShellScriptBin "mcpjam"  ''
      #!/usr/bin/env bash
      npx @mcpjam/inspector@latest "$@"
    '')
  ];
}
