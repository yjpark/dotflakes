{pkgs, ...}: {
  home.packages = with pkgs; [
    google-chrome
    obsidian
    bitwarden-desktop
    microsoft-edge
    # rustdesk
    vlc
    qimgv
    nomacs
    kdePackages.kimageformats
    # synergy
    oculante
    darktable
    # mattermost-desktop
    vulkan-tools
    ydotool
    gnome-randr
    gjs # JavaScript bindings for GNOME
    clash-verge-rev # clash gui
    # others
    discord
  ];
}
