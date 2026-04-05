# Explicit NixOS configurations, modules, and overlays
# Replaces nixos-unified autoWire
{ inputs, flakeInputs, ... }:
let
  specialArgs = {
    flake = { inputs = flakeInputs; };
  };

  mkNixosConfig = dir: name:
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      modules = [ (inputs.self + /configurations/nixos/${dir}/${name}) ];
    };

  hosts = [ "edger" "a13" "g1" "p2" "pc" ];
  containers = [ "yolo" "spacebot" "hermes" ];

  hostConfigs = builtins.listToAttrs (map (name: {
    inherit name;
    value = mkNixosConfig "hosts" name;
  }) hosts);

  containerConfigs = builtins.listToAttrs (map (name: {
    inherit name;
    value = mkNixosConfig "containers" name;
  }) containers);
in
{
  flake = {
    nixosConfigurations = hostConfigs // containerConfigs;
    overlays.default = import (inputs.self + /overlays);
  };
}
