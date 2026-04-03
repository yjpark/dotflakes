{
  description = "YJ Park's Home Manager Configuration";
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

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

    ## https://flox.dev/docs/install-flox/install/#__tabbed_1_5
    flox.url = "github:flox/flox/latest";

    # https://nixidy.dev/user_guide/getting_started/
    nixidy.url = "github:arnarg/nixidy";

    # vscode-server
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.flake = false;

    # https://github.com/Svenum/Solaar-Flake
    solaar.url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
    solaar.inputs.nixpkgs.follows = "nixpkgs";

    # AI Tools
    llm-agents.url = "github:numtide/llm-agents.nix";
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";

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

  # Wired using https://nixos-unified.org/autowiring.html
  outputs = inputs:
    inputs.nixos-unified.lib.mkFlake {
      inputs = inputs // { autowire = inputs.jig.lib.autowire; };
      root = ./.;
    };
}
