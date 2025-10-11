{ flake, pkgs, ... }: {
  home.packages = with pkgs; [
    flake.inputs.nixidy.packages.${system}.default
  ];
}
