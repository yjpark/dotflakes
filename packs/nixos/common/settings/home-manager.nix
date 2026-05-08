{ flake, lib, pkgs, ... }:
let
  inherit (flake) inputs;
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = lib.mkForce false;
    useUserPackages = lib.mkForce false;
    extraSpecialArgs = {
      flake = { inherit inputs; };
      currentSystem = pkgs.stdenv.hostPlatform.system;
    };
  };
}
