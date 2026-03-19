{ self, lib, ... }:
let
  mkHomeConfigs = { baseConfigPath, mixinDir, username }:
    pkgs:
    let
      entries = builtins.readDir (self + mixinDir);
      hosts = map (name:
        if entries.${name} == "regular" then lib.removeSuffix ".nix" name else name
      ) (builtins.filter (name: name != "default.nix")
        (builtins.attrNames entries));
      mkHostModule = host: {
        imports = [ (self + baseConfigPath) (self + mixinDir + "/${host}.nix") ];
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
      baseConfigPath = "/configurations/home/yjpark.nix";
      mixinDir = "/mixins/home/hosts";
      username = "yjpark";
    } pkgs)
    //
    (mkHomeConfigs {
      baseConfigPath = "/configurations/home/yj.nix";
      mixinDir = "/mixins/home/containers";
      username = "yj";
    } pkgs);
in {
  perSystem = { pkgs, ... }: {
    legacyPackages = lib.mkForce { homeConfigurations = mkAllConfigs pkgs; };
  };
}
