{
  description = "YJ Park's Home Manager Configuration";
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flakelight.url = "github:nix-community/flakelight";
    flakelight.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-unified.url = "github:srid/nixos-unified";

    # Tools
    autowire.url = "github:yjpark/autowire.nix";

    # Software inputs
    ## https://nix-community.github.io/nixvim/index.html
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.flake-parts.follows = "flake-parts";

    ## https://flox.dev/docs/install-flox/install/#__tabbed_1_5
    flox.url = "github:flox/flox/latest";

    # https://nixidy.dev/user_guide/getting_started/
    nixidy.url = "github:arnarg/nixidy";
  };

  # Wired using https://nixos-unified.org/autowiring.html
  outputs = inputs:
    inputs.flakelight ./. {
      nixDirAliases.homeModules = [ "home" ];
    }
    #inputs.nixos-unified.lib.mkFlake
    #  { inherit inputs; root = ./.; };
}
