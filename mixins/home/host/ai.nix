{
  flake,
  pkgs,
  ...
}:
let
    dolt-version = "1.83.5";
    dolt = pkgs.dolt.overrideAttrs (old: {
      version = dolt-version;
      src = pkgs.fetchFromGitHub {
        owner = "dolthub";
        repo = "dolt";
        tag = "v${dolt-version}";
        hash = "sha256-UaC9Yl3xl3IWQN7RSu1ApJNgm/fIgvLgoxOFWEVJK28=";
      };
      vendorHash = "sha256-hnJhLEJo/EQlTuTv+smiLok7AarFoDIB4ebB6ncUYtc=";
      doCheck = false;
    });
in
{
  programs.claude-code.package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    gemini-cli
    openspec
    opencode
    claudebox
    ccusage
    ck
    pkgs.beans
    beads
    dolt
    #backlog-md
    #vibe-kanban
    #agent-browser
    #skills-installer

    pkgs.bun # needed by ccusage statusline
    pkgs.nodejs_25 # needed by context7

    (pkgs.writeShellScriptBin "clone-beans" ''
      #!/usr/bin/env bash

      mkdir -p ~/tools/
      cd ~/tools/
      git clone https://github.com/hmans/beans.git
      cd beans
      git remote add yjpark git@github.com:yjpark/beans.git
      jj git init --colocate
    '')

    (pkgs.writeShellScriptBin "install-ccline"  ''
      #!/usr/bin/env bash

      npm install -g @cometix/ccline
    '')

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
