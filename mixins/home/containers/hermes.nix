{flake, pkgs, ...}: let
  inherit (flake) inputs;
in {
  home.packages = [
    inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
