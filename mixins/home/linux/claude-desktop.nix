{
  flake,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    flake.inputs.claude-desktop.packages.${stdenv.hostPlatform.system}.claude-desktop-fhs
  ];
}

