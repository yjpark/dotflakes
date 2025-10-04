{ pkgs, ... }: {
  home.packages = with pkgs; [
    omnix
  ];
}
