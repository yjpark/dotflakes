{ config, lib, ... }: {
  networking.firewall.enable = false;
  networking.nftables.enable = true;
  services.firewalld.enable = true;

  # The nixpkgs services.firewalld module writes zone/service config to
  # /etc/firewalld/{zones,services}/*.xml but never wires those files to the
  # systemd unit. As a result `switch-host` applies the new XML while the
  # running daemon keeps the old rules until a manual `systemctl restart`.
  # Reload firewalld whenever any generated firewalld config file changes.
  # The unit's ExecReload sends SIGHUP, on which firewalld reloads its
  # permanent config into runtime — non-disruptive (no flush of connections).
  systemd.services.firewalld.reloadTriggers = lib.mapAttrsToList (_: v: v.source) (
    lib.filterAttrs (name: _: lib.hasPrefix "firewalld/" name) config.environment.etc
  );
}
