{ self, inputs, ... }:
let
  knownHosts = builtins.attrNames (builtins.readDir (self + /configurations/incus));
in {
  perSystem = { self', pkgs, lib, ... }: {
    apps = inputs.nixos-incus-containers.lib.makeHelperApps {
      inherit pkgs;
      containerName = "yolo";
      flakeOutPath = self.outPath;
    };
  };
}
