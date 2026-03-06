{
  flake,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    flake.inputs.nixidy.packages.${stdenv.hostPlatform.system}.default
  ];
}
