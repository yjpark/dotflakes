{ self, lib, ... }:
let
  nixosHosts = builtins.attrNames (builtins.readDir (self + /configurations/nixos));
  baseConfigPath = self + /configurations/home/yjpark.nix;
  hostMixinDir = self + /mixins/home/hosts;
  hasHostMixin = host: builtins.pathExists (hostMixinDir + "/${host}.nix");

  mkHostModule = host: {
    imports = [ baseConfigPath ]
      ++ lib.optional (hasHostMixin host) (hostMixinDir + "/${host}.nix");
  };

  mkAllConfigs = pkgs:
    let
      hostConfigs = lib.listToAttrs (map (host:
        lib.nameValuePair "yjpark@${host}"
          (self.nixos-unified.lib.mkHomeConfiguration pkgs (mkHostModule host))
      ) nixosHosts);
      fallback = {
        yjpark = self.nixos-unified.lib.mkHomeConfiguration pkgs baseConfigPath;
      };
    in fallback // hostConfigs;
in {
  perSystem = { pkgs, ... }: {
    legacyPackages = lib.mkForce { homeConfigurations = mkAllConfigs pkgs; };
  };
}
