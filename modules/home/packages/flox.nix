{ flake, pkgs, ... }: {
  home.packages = with pkgs; [
    flake.inputs.flox.packages.${system}.default
  ];
}
