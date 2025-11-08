{pkgs, ...}: {
  home.packages = with pkgs; [
    niri

    # Wayland tools
    wl-clipboard
    wayland-utils
    xwayland-satellite
  ];
  programs.fuzzel.enable = true;
  programs.rofi = {
    enable = true;
    plugins = with pkgs; [
      rofi-file-browser
      rofi-emoji
    ];
  };
}
