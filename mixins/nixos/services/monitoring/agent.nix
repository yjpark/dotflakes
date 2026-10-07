{ config, lib, ... }:
# Agent: scrape this host and write to every hub (see default.nix).
#
# vmagent keeps a separate on-disk queue per -remoteWrite.url, so a hub that is
# unreachable (e.g. the ZeroTier link between sites is down) only backs up its
# own queue; the other hub keeps receiving, and the backlog replays once the
# link returns.
#
# Everything here binds to localhost: hubs receive by push, nothing scrapes in.
let
  cfg = config.monitoring;
  hostName = config.networking.hostName;

  # instance is normally the scrape address, which is 127.0.0.1:<port> on every
  # host; replace it with the host name so dashboards keyed on instance work.
  localJob = name: port: extra: {
    job_name = name;
    static_configs = [{ targets = [ "127.0.0.1:${toString port}" ]; }];
    relabel_configs = [{
      target_label = "instance";
      replacement = hostName;
    }];
  } // extra;
in
{
  config = lib.mkIf cfg.role.agent {
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = cfg.ports.nodeExporter;
      # systemd: per-unit state, so failed units are queryable.
      enabledCollectors = [ "systemd" "processes" ];
    };

    services.vmagent = {
      enable = true;
      # remoteWrite.url takes a single URL; all hubs go through extraArgs.
      extraArgs = [
        "-httpListenAddr=127.0.0.1:${toString cfg.ports.vmagent}"
        "-remoteWrite.tmpDataPath=%C/vmagent/remote_write_tmp"
        "-remoteWrite.maxDiskUsagePerURL=1GB"
      ] ++ map (url: "-remoteWrite.url=${url}") cfg.vmWriteUrls;

      prometheusConfig = {
        global = {
          scrape_interval = "30s";
          external_labels = cfg.labels;
        };
        scrape_configs = [
          (localJob "node" cfg.ports.nodeExporter { })
          (localJob "vmagent" cfg.ports.vmagent { })
        ] ++ lib.optionals cfg.role.hub [
          (localJob "victoriametrics" cfg.ports.victoriametrics { })
          (localJob "victorialogs" cfg.ports.victorialogs { })
        ];
      };
    };
  };
}
