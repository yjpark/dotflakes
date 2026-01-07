{pkgs, ...}: {
  home.packages = with pkgs; [
    microsoft-edge
    rustdesk
    vlc
    qimgv
    # synergy
    oculante
    #darktable
    #mattermost-desktop
    vulkan-tools
    ydotool
    gnome-randr
    gjs # JavaScript bindings for GNOME
    clash-verge-rev # clash gui
  ];
}
