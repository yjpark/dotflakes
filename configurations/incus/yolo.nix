{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
inputs.nixos-incus-containers.lib.makeIncusHost {
  name = "yolo";
  modules = [
    {
      networking.hostName = "yolo";
    }
  ];
}
