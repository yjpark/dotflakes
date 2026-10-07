{ config, lib, ... }:
# Hub: storage + built-in UIs for the whole fleet. Every agent writes to every
# hub (see default.nix), so each hub holds the full dataset.
#
#   VictoriaMetrics  http://<hub>:8428/vmui
#   VictoriaLogs     http://<hub>:9428/select/vmui
#
# Both listen on all interfaces. ZeroTier is in the firewalld trusted zone; the
# site's lan zone already admits its own /24 on all ports, and nothing else is
# opened, so this stays reachable from ZeroTier and the local site only.
let
  cfg = config.monitoring;
in
{
  options.monitoring.retention = {
    metrics = lib.mkOption {
      type = lib.types.str;
      default = "90d";
      description = "VictoriaMetrics -retentionPeriod.";
    };

    logs = lib.mkOption {
      type = lib.types.str;
      default = "30d";
      description = "VictoriaLogs -retentionPeriod.";
    };

    logsMaxDiskBytes = lib.mkOption {
      type = lib.types.int;
      default = 20 * 1024 * 1024 * 1024;
      description = ''
        VictoriaLogs -retention.maxDiskSpaceUsageBytes: oldest partitions are
        dropped past this, whatever the retention period says.
      '';
    };
  };

  config = lib.mkIf cfg.role.hub {
    services.victoriametrics = {
      enable = true;
      listenAddress = ":${toString cfg.ports.victoriametrics}";
      retentionPeriod = cfg.retention.metrics;
    };

    services.victorialogs = {
      enable = true;
      listenAddress = ":${toString cfg.ports.victorialogs}";
      extraOptions = [
        "-retentionPeriod=${cfg.retention.logs}"
        "-retention.maxDiskSpaceUsageBytes=${toString cfg.retention.logsMaxDiskBytes}"
      ];
    };
  };
}
