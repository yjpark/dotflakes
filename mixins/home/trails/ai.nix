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
  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    ck
    beads
    dolt

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
