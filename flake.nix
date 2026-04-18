{
  description = "YJ Park's Home Manager Configuration";
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";


    # Tools
    jig.url = "github:edger-dev/jig";

    # Software inputs
    ## https://github.com/Mic92/sops-nix
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    ## https://nix-community.github.io/nixvim/index.html
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.flake-parts.follows = "flake-parts";

    # vscode-server
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.flake = false;

    # https://github.com/Svenum/Solaar-Flake
    solaar.url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

    # AI Tools
    llm-agents.url = "github:numtide/llm-agents.nix";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian/218934d14dd19637520a000bd807cb8db3e074cd"; # pinned: newer versions have node-pty permission bug

    # OpenCode plugin that delegates to Claude Code CLI as the AI provider
    # https://github.com/unixfox/opencode-claude-code-plugin
    opencode-claude-code-plugin.url = "github:unixfox/opencode-claude-code-plugin";
    opencode-claude-code-plugin.flake = false;

    # https://github.com/spacedriveapp/spacebot
    spacebot.url = "github:yjpark/spacebot/fix/frontend-node-modules-hash";


    # https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
    hermes-agent.url = "github:NousResearch/hermes-agent";

    # https://github.com/nesquena/hermes-webui
    hermes-webui.url = "github:nesquena/hermes-webui";
    hermes-webui.flake = false;

    # https://github.com/jacopone/antigravity-nix
    antigravity.url = "github:jacopone/antigravity-nix";
    antigravity.inputs.nixpkgs.follows = "nixpkgs";

    # https://github.com/edger-dev/mdbook-beans
    mdbook-beans.url = "github:edger-dev/mdbook-beans";
    mdbook-beans.inputs.nixpkgs.follows = "nixpkgs";

    # the unrealsed v0.10 version is much better
    # https://github.com/idursun/jjui/discussions/319
    jjui.url = "github:idursun/jjui";

    # Need latest niri to support the displaylink
    niri.url = "github:yjpark/niri/fix-display-only-linear-buffers";

    # https://github.com/xremap/nix-flake/blob/master/docs/HOWTO.md#nixos
    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" ];
      _module.args = {
        # Make autowire available as a top-level arg in flake-parts modules
        flakeInputs = inputs // { autowire = inputs.jig.lib.autowire; };
      };
      imports = [
        ./flake/toplevel.nix
        ./flake/nixos-configs.nix
        ./flake/home-configs.nix
        ./flake/activate-home.nix
        ./flake/docs.nix
      ];
    };
}
