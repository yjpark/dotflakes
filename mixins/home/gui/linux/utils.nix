{pkgs, ...}: {
  home.packages = with pkgs; [
    xev
    libinput
  ];
}
