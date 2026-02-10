{
  flake,
  pkgs,
  ...
}: {
  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    openspec
    opencode
    ccusage
    ck
    vibe-kanban
    agent-browser
    claudebox
    skills-installer

    pkgs.nodejs_25 # needed by context7
    (pkgs.writeShellScriptBin "mcpjam"  ''
      #!/usr/bin/env bash
      npx @mcpjam/inspector@latest "$@"
    '')
  ];


}
