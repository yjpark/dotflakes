{
  flake,
  pkgs,
  ...
}: {
  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    flake.inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
    openspec
    opencode
    claudebox
    ccusage
    ck
    backlog-md
    beads
    #vibe-kanban
    #agent-browser
    #skills-installer

    pkgs.bun # needed by ccusage statusline
    pkgs.nodejs_25 # needed by context7

    (pkgs.writeShellScriptBin "install-happy"  ''
      #!/usr/bin/env bash

      npm install -g happy-coder
      npm install -g @anthropic-ai/claude-code
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
