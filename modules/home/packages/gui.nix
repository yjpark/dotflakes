{pkgs, ...}: {
  home.packages = with pkgs; [
    discord
    bitwarden-desktop
    google-chrome
    obsidian
  ];
}
