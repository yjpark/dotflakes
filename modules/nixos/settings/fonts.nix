{pkgs, ...}: {
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.hurmit
      nerd-fonts.fira-code
    ];
  };
}
