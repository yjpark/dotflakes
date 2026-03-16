{ self, lib, ... }:
let
  nixosHosts = builtins.attrNames (builtins.readDir (self + /configurations/incus));
  baseConfigPath = self + /configurations/home/yj.nix;
  hostMixinDir = self + /mixins/home/containers;
  hasHostMixin = host: builtins.pathExists (hostMixinDir + "/${host}.nix");

  mkHostModule = host: {
    imports = [ baseConfigPath ]
      ++ lib.optional (hasHostMixin host) (hostMixinDir + "/${host}.nix");
  };

  mkAllConfigs = pkgs:
    let
      hostConfigs = lib.listToAttrs (map (host:
        lib.nameValuePair "yj@${host}"
          (self.nixos-unified.lib.mkHomeConfiguration pkgs (mkHostModule host))
      ) nixosHosts);
      fallback = {
        yj = self.nixos-unified.lib.mkHomeConfiguration pkgs baseConfigPath;
      };
    in fallback // hostConfigs;
in {
  perSystem = { pkgs, ... }: {
    legacyPackages = lib.mkForce { homeConfigurations = mkAllConfigs pkgs; };
  };
}
