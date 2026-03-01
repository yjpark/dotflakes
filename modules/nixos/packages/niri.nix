{
  flake,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri
  ];
}
