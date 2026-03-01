{pkgs, ...}: {
  home.packages = with pkgs; [
    cosmic-ext-tweaks   
    jq
    (writeShellScriptBin "install-cos-cli" ''
      #!/usr/bin/env bash
      cargo install --git https://github.com/estin/cos-cli
    '')
    (writeShellScriptBin "cos-activate-chrome" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("google-chrome")')
    '')
    (writeShellScriptBin "cos-activate-zed" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("dev.zed.zed")')
    '')
    (writeShellScriptBin "cos-activate-edge" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("microsoft-edge")')
    '')
    (writeShellScriptBin "cos-activate-kitty" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("kitty")')
    '')
    (writeShellScriptBin "cos-activate-obsidian" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("obsidian")')
    '')
    (writeShellScriptBin "cos-activate-antigravity" ''
      #!/usr/bin/env bash
      ~/.cargo/bin/cos-cli activate -i $(~/.cargo/bin/cos-cli info --json | ~/.nix-profile/bin/jq '[.apps[].app_id | ascii_downcase] | index("antigravity")')
    '')
  ];
}
