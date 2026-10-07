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

  # groupname is "<comm>|[<cgroup>]" (Go's formatting of a one-element cgroup
  # v2 list). Split it into labels and drop the original.
  processJob.metric_relabel_configs = [
    {
      source_labels = [ "groupname" ];
      regex = "(.*)\\|\\[(.*)\\]";
      target_label = "comm";
      replacement = "$1";
    }
    {
      source_labels = [ "groupname" ];
      regex = "(.*)\\|\\[(.*)\\]";
      target_label = "cgroup";
      replacement = "$2";
    }
    {
      # Last cgroup path element: nix-daemon.service, session-3.scope, ...
      source_labels = [ "cgroup" ];
      regex = "(?:.*/)?([^/]+)";
      target_label = "unit";
      replacement = "$1";
    }
    { regex = "groupname"; action = "labeldrop"; }
  ];
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

    # Per-process usage, grouped by (command name, cgroup) so a single exporter
    # answers both "top processes" and "which service / container / pod". The
    # cgroup covers systemd units and incus containers (lxc.payload.*).
    # vmagent splits the group name into comm/cgroup/unit labels (see
    # processJob). Kernel threads have no cmdline and are not matched; host-wide
    # CPU already comes from node_exporter.
    #
    # Runs as an unprivileged user, so per-process io and smaps of other users
    # are unreadable; CPU and RSS come from /proc/<pid>/stat and status, which
    # are world-readable. Per-thread metrics are off to bound cardinality.
    services.prometheus.exporters.process = {
      enable = true;
      listenAddress = "127.0.0.1";
      port = cfg.ports.processExporter;
      settings.process_names = [{
        name = "{{.Comm}}|{{.Cgroups}}";
        cmdline = [ ".+" ];
      }];
      extraFlags = [
        "-threads=false"
        "-gather-smaps=false"
        "-remove-empty-groups"
      ];
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
          (localJob "process" cfg.ports.processExporter processJob)
          (localJob "vmagent" cfg.ports.vmagent { })
        ] ++ lib.optionals cfg.role.hub [
          (localJob "victoriametrics" cfg.ports.victoriametrics { })
          (localJob "victorialogs" cfg.ports.victorialogs { })
        ];
      };
    };
  };
}
