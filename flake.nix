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
    autowire.url = "github:yjpark/autowire.nix";

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

    # https://docs.noctalia.dev/getting-started/nixos/
    quickshell.url = "github:outfoxxed/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.quickshell.follows = "quickshell";

    # vscode-server
    nixos-vscode-server.url = "github:nix-community/nixos-vscode-server";
    nixos-vscode-server.flake = false;

    # https://github.com/Svenum/Solaar-Flake
    solaar.url = "https://flakehub.com/f/Svenum/Solaar-Flake/*.tar.gz";
    solaar.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Wired using https://nixos-unified.org/autowiring.html
  outputs = inputs:
    inputs.nixos-unified.lib.mkFlake
    {
      inherit inputs;
      root = ./.;
    };
}
