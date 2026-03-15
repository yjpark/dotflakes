{ flake, lib, config, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
  baseConfigPath = self + /configurations/home/yjpark.nix;
  hostMixinDir = self + /mixins/home/hosts;
  hostname = config.networking.hostName;
  hasHostMixin = builtins.pathExists (hostMixinDir + "/${hostname}.nix");
in {
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    useGlobalPkgs = lib.mkForce false;
    useUserPackages = lib.mkForce false;
    extraSpecialArgs = { flake = { inherit inputs; }; };
    users.yjpark = {
      imports = [ baseConfigPath ]
        ++ lib.optional hasHostMixin (hostMixinDir + "/${hostname}.nix");
    };
  };
}
