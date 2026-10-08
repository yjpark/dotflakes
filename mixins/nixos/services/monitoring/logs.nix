{ config, lib, pkgs, ... }:
# Ship this host's journal to every hub (see default.nix).
#
#   journald --systemd-journal-upload--> vlagent (127.0.0.1) --> VictoriaLogs on each hub
#
# systemd-journal-upload takes a single URL, so it hands entries to a local
# vlagent, which accepts the journald protocol itself (vlagent embeds vlinsert)
# and keeps a separate on-disk queue per hub, like vmagent does for metrics.
# Stream fields are applied by vlagent; the defaults (_MACHINE_ID, _HOSTNAME,
# _SYSTEMD_UNIT) are what we want.
let
  cfg = config.monitoring;

  # nixpkgs builds vlagent only on request; it has no NixOS module either.
  vlagent = pkgs.victorialogs.override {
    withServer = false;
    withVlAgent = true;
  };

  # With no saved cursor, systemd-journal-upload starts at the oldest entry.
  # Hubs drop anything older than their retention anyway, so on first start
  # point the cursor at the last entry before the retention window instead of
  # pushing the whole journal across sites. If the journal is younger than the
  # window, there is no such entry and everything is uploaded.
  seedCursor = pkgs.writeShellScript "journal-upload-seed-cursor" ''
    state="$STATE_DIRECTORY/state"
    [ -e "$state" ] && exit 0
    cursor=$(${config.systemd.package}/bin/journalctl --quiet --until=-${cfg.retention.logs} \
      --lines=1 --show-cursor --output=cat | ${pkgs.gnused}/bin/sed -n 's/^-- cursor: //p')
    if [ -n "$cursor" ]; then
      printf '# This is private data. Do not parse.\nLAST_CURSOR=%s\n' "$cursor" > "$state"
    fi
  '';
in
{
  config = lib.mkIf cfg.role.agent {
    systemd.services.vlagent = {
      description = "VictoriaLogs agent: journald in, every hub out";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = lib.escapeShellArgs ([
          "${vlagent}/bin/vlagent"
          "-httpListenAddr=127.0.0.1:${toString cfg.ports.vlagent}"
          "-tmpDataPath=%S/vlagent"
          "-remoteWrite.maxDiskUsagePerURL=1GB"
        ] ++ map (url: "-remoteWrite.url=${url}") cfg.vlWriteUrls);
        DynamicUser = true;
        StateDirectory = "vlagent";
        Restart = "on-failure";
      };
    };

    services.journald.upload = {
      enable = true;
      # systemd-journal-upload appends /upload to this.
      settings.Upload.URL = "http://127.0.0.1:${toString cfg.ports.vlagent}/insert/journald";
    };

    systemd.services.systemd-journal-upload = {
      after = [ "vlagent.service" ];
      wants = [ "vlagent.service" ];
      serviceConfig.ExecStartPre = [ seedCursor ];
    };
  };
}
