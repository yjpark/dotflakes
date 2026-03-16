{ self, lib, ... }:
let
  mkHomeConfigs = { configDir, baseConfigPath, mixinDir, username }:
    pkgs:
    let
      hosts = builtins.attrNames (builtins.readDir (self + configDir));
      hasHostMixin = host: builtins.pathExists (self + mixinDir + "/${host}.nix");
      mkHostModule = host: {
        imports = [ (self + baseConfigPath) ]
          ++ lib.optional (hasHostMixin host) (self + mixinDir + "/${host}.nix");
      };
      hostConfigs = lib.listToAttrs (map (host:
        lib.nameValuePair "${username}@${host}"
          (self.nixos-unified.lib.mkHomeConfiguration pkgs (mkHostModule host))
      ) hosts);
      fallback = {
        ${username} = self.nixos-unified.lib.mkHomeConfiguration pkgs (self + baseConfigPath);
      };
    in fallback // hostConfigs;

  mkAllConfigs = pkgs:
    (mkHomeConfigs {
      configDir = "/configurations/nixos";
      baseConfigPath = "/configurations/home/yjpark.nix";
      mixinDir = "/mixins/home/hosts";
      username = "yjpark";
    } pkgs)
    //
    (mkHomeConfigs {
      configDir = "/configurations/incus";
      baseConfigPath = "/configurations/home/yj.nix";
      mixinDir = "/mixins/home/containers";
      username = "yj";
    } pkgs);
in {
  perSystem = { pkgs, ... }: {
    legacyPackages = lib.mkForce { homeConfigurations = mkAllConfigs pkgs; };
  };
}
