{
  flake,
  pkgs,
  ...
}: {
  home.pointerCursor = {
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 48;
    gtk.enable = true;
    x11.enable = true;
  };

  home.packages = with pkgs; [
    flake.inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri
    nirius

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
  programs.tofi = {
    enable = true;
  };
  programs.swaylock = {
    enable = true;
  };
}
