{flake, ...}: let
  inherit (flake) inputs;
  inherit (inputs) self;
in {
  imports = [
    ./yjpark-cli.nix
    (self + /packs/home/gui)
  ];
}
