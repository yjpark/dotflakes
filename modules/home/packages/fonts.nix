{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hurmit
  ];
}
