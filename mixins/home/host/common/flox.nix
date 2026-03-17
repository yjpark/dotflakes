{
  flake,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    flake.inputs.flox.packages.${stdenv.hostPlatform.system}.default
  ];
}
