{
  description = "YJ Park's Home Manager Configuration";
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flakelight.url = "github:nix-community/flakelight";
    flakelight.inputs.nixpkgs.follows = "nixpkgs";

    # Tools
    autowire.url = "github:yjpark/autowire.nix";

    # Software inputs
    ## https://nix-community.github.io/nixvim/index.html
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    ## https://flox.dev/docs/install-flox/install/#__tabbed_1_5
    flox.url = "github:flox/flox/latest";

    # https://nixidy.dev/user_guide/getting_started/
    nixidy.url = "github:arnarg/nixidy";
  };

  # Wired using https://nixos-unified.org/autowiring.html
  outputs = inputs:
    inputs.flakelight ./. {
      inherit inputs;
      nixDirAliases = {
        nixosConfigurations = [ "hosts" ];
        homeConfigurations = [ "users" ];
        nixosModules = [ "nixos" ];
        homeModules = [ "home" ];
        devShells = [ "shells" ];
        withOverlays = [ "overlays" ];
      };
    };
}
