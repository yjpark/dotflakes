{pkgs, ...}: {
  home.packages = with pkgs; [
    nodejs_25
    (pkgs.writeShellScriptBin "ai-install-gemini-cli"  ''
      #!/usr/bin/env bash
      npm install -g @google/gemini-cli@latest
    '')
  ];
}
