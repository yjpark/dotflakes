{
  flake,
  pkgs,
  ...
}:
{
  programs.claude-code.package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    gemini-cli
    #pkgs.beans

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
  ];
}
