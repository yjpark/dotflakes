{...}: {
  # When keep running with lid closed, might got warning in systemd-logind
  services.logind.settings.Login.lidSwitch = "lock";

  # https://discourse.nixos.org/t/stop-pc-from-sleep/5757
  # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
  # If no user is logged in, the machine will power down after 20 minutes.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
}
