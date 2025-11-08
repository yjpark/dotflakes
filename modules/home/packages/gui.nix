{pkgs, ...}: {
  home.packages = with pkgs; [
    discord
    bitwarden-desktop
    microsoft-edge
    google-chrome
    obsidian
    rustdesk
  ];
}
