{
  flake,
  pkgs,
  ...
}: {
  home.packages = [
    flake.inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}

