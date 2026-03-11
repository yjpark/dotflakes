{
  flake,
  pkgs,
  ...
}: {
  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    openspec
    opencode
    claudebox
    ccusage
    ck
    backlog-md
    pkgs.beans
    beads
    #vibe-kanban
    #agent-browser
    #skills-installer

    pkgs.bun # needed by ccusage statusline
    pkgs.nodejs_25 # needed by context7

    (pkgs.writeShellScriptBin "install-googleworkspace-cli"  ''
      #!/usr/bin/env bash

      npm install -g @googleworkspace/cli
    '')

    (pkgs.writeShellScriptBin "install-claude-trace"  ''
      #!/usr/bin/env bash

      npm install -g @mariozechner/claude-trace
    '')

    (pkgs.writeShellScriptBin "mcpjam"  ''
      #!/usr/bin/env bash
      npx @mcpjam/inspector@latest "$@"
    '')
  ];


}
