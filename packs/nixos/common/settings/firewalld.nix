{ config, lib, pkgs, ... }: {
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

  # ...except the reload itself was broken, so the triggers above never did
  # anything. The unit ends up with two ExecReload= lines: firewalld's own
  # packaged `/bin/kill -HUP $MAINPID`, which does not exist on NixOS, and the
  # correct coreutils path that the nixpkgs module adds as a drop-in. systemd
  # appends Exec* directives rather than replacing them, so the broken one runs
  # first and fails the whole reload with 203/EXEC:
  #
  #   firewalld.service: Failed at step EXEC spawning /bin/kill: No such file
  #
  # The leading "" resets the list before adding the working command. Upstream
  # bug: the module sets serviceConfig.ExecReload to a bare string instead of
  # a list beginning with "".
  systemd.services.firewalld.serviceConfig.ExecReload = lib.mkForce [
    ""
    "${lib.getExe' pkgs.coreutils "kill"} -HUP $MAINPID"
  ];
}
