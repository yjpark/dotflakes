# Home Manager configurations
# Generates username@host entries from mixins/home/hosts/ and mixins/home/containers/
{ inputs, lib, flakeInputs, ... }:
let
  specialArgs = {
    flake = { inputs = flakeInputs; };
  };

  mkHomeConfigs = { baseConfigPath, mixinDir, username }:
    pkgs:
    let
      entries = builtins.readDir (inputs.self + mixinDir);
      hosts = map (name:
        if entries.${name} == "regular" then lib.removeSuffix ".nix" name else name
      ) (builtins.filter (name: name != "default.nix")
        (builtins.attrNames entries));
      mkHostModule = host: let
        hostPath = if entries ? "${host}.nix" then "/${host}.nix" else "/${host}";
      in {
        imports = [ (inputs.self + baseConfigPath) (inputs.self + mixinDir + hostPath) ];
      };
      hostConfigs = lib.listToAttrs (map (host:
        lib.nameValuePair "${username}@${host}"
          (inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = specialArgs;
            modules = [ (mkHostModule host) ];
          })
      ) hosts);
      fallback = {
        ${username} = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = specialArgs;
          modules = [ (inputs.self + baseConfigPath) ];
        };
      };
    in fallback // hostConfigs;

  mkAllConfigs = pkgs:
    (mkHomeConfigs {
      baseConfigPath = "/home/yjpark.nix";
      mixinDir = "/mixins/home/hosts";
      username = "yjpark";
    } pkgs)
    //
    (mkHomeConfigs {
      baseConfigPath = "/home/yj.nix";
      mixinDir = "/mixins/home/containers";
      username = "yj";
    } pkgs);
in {
  perSystem = { pkgs, ... }: {
    legacyPackages = lib.mkForce { homeConfigurations = mkAllConfigs pkgs; };
  };
}
