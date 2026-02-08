{pkgs, ...}: {
  home.packages = with pkgs; [
    goose-cli
    nodejs_25
    (pkgs.writeShellScriptBin "mcpjam"  ''
      #!/usr/bin/env bash
      npx @mcpjam/inspector@latest "$@"
    '')
  ];
}
