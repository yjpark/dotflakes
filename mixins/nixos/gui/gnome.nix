{pkgs, ...}: {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "dvorak";
    options = "ctrl:swapcaps";
  };

  services.xserver.exportConfiguration = true;
  environment.systemPackages = with pkgs.gnomeExtensions; [
    pkgs.dconf
    pkgs.gnome-tweaks
    unite
    appindicator
    pano
    hibernate-status-button
    vitals
    run-or-raise
    undecorate
    panel-to-bottom
  ];
  services.gnome.gcr-ssh-agent.enable = false;
}
