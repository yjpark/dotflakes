{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    bun # needed by ccusage statusline
    nodejs_25 # needed by context7

    (writeShellScriptBin "clone-beans" ''
      #!/usr/bin/env bash

      mkdir -p ~/tools/
      cd ~/tools/
      git clone https://github.com/hmans/beans.git
      cd beans
      git remote add yjpark git@github.com:yjpark/beans.git
      jj git init --colocate
    '')

    (writeShellScriptBin "install-ccline"  ''
      #!/usr/bin/env bash

      npm config set prefix ~/.npm
      npm install -g @cometix/ccline
    '')
  ];
}

