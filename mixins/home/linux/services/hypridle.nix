{pkgs, ...}: {
  services.hypridle = {
    enable = true;
    settings = {
      listener = [
        {
          timeout = 300; # 5 minutes
          on-timeout = "niri msg action power-off-monitors";
        }
      ];
    };
  };
  # Having issue with systemd service, missing WAYLAND_DISPLAY environment
  home.packages = with pkgs; [
    hypridle
  ];
}
