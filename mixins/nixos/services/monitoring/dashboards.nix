{ config, lib, pkgs, ... }:
# vmui dashboards, served by every hub via -vmui.customDashboardsPath (Dashboards
# tab at http://<hub>:8428/vmui). vmui has no template variables, so there is an
# overview comparing hosts plus one dashboard per entry in monitoring.hosts.
#
# Format: VictoriaMetrics app/vmui/packages/vmui/public/dashboards. `unit` is a
# plain suffix with no scaling, so expressions convert to %/MiB/GiB themselves.
let
  cfg = config.monitoring;

  panel = width: title: unit: expr: alias: {
    inherit title unit width;
    expr = [ expr ];
    alias = [ alias ];
  };

  overview = {
    title = "Hosts overview";
    rows = [
      {
        title = "Health";
        panels = [
          (panel 4 "Up (node exporter)" "" ''up{job="node"}'' "{{host}}")
          (panel 4 "Failed systemd units" "" ''sum by (host) (node_systemd_unit_state{state="failed"})'' "{{host}}")
          (panel 4 "Load (5m)" "" ''node_load5'' "{{host}}")
        ];
      }
      {
        title = "Resources";
        panels = [
          (panel 4 "CPU" "%" ''100 * (1 - avg by (host) (rate(node_cpu_seconds_total{mode="idle"}[5m])))'' "{{host}}")
          (panel 4 "Memory used" "%" ''100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)'' "{{host}}")
          (panel 4 "Fullest filesystem" "%" ''max by (host) (100 * (1 - node_filesystem_avail_bytes{fstype!~"tmpfs|ramfs|overlay|squashfs|nsfs"} / node_filesystem_size_bytes))'' "{{host}}")
        ];
      }
    ];
  };

  hostDashboard = host:
    let
      s = ''host="${host}"'';
      cpuBy = by: ''topk(10, sum by (${by}) (rate(namedprocess_namegroup_cpu_seconds_total{${s}}[5m])) * 100)'';
      rssBy = by: ''topk(10, sum by (${by}) (namedprocess_namegroup_memory_bytes{${s},memtype="resident"}) / 2^20)'';
    in
    {
      title = "Host: ${host}";
      rows = [
        {
          title = "System";
          panels = [
            (panel 3 "CPU by mode" "%" ''100 * sum by (mode) (rate(node_cpu_seconds_total{${s},mode!="idle"}[5m])) / scalar(count(node_cpu_seconds_total{${s},mode="idle"}))'' "{{mode}}")
            (panel 3 "Memory available" "GiB" ''node_memory_MemAvailable_bytes{${s}} / 2^30'' "available")
            (panel 3 "Filesystem used" "%" ''100 * (1 - node_filesystem_avail_bytes{${s},fstype!~"tmpfs|ramfs|overlay|squashfs|nsfs"} / node_filesystem_size_bytes)'' "{{mountpoint}}")
            (panel 3 "Load" "" ''node_load1{${s}}'' "load1")
          ];
        }
        {
          title = "Network / disk";
          panels = [
            (panel 6 "Network receive" "MiB/s" ''sum by (device) (rate(node_network_receive_bytes_total{${s},device!~"lo|veth.*|cali.*|flannel.*|cni.*"}[5m])) / 2^20'' "{{device}}")
            (panel 6 "Disk I/O" "MiB/s" ''sum by (device) (rate(node_disk_read_bytes_total{${s}}[5m]) + rate(node_disk_written_bytes_total{${s}}[5m])) / 2^20'' "{{device}}")
          ];
        }
        {
          title = "Top services / containers (by cgroup)";
          panels = [
            (panel 6 "CPU" "%" (cpuBy "cgroup") "{{cgroup}}")
            (panel 6 "RSS" "MiB" (rssBy "cgroup") "{{cgroup}}")
          ];
        }
        {
          title = "Top processes (by command)";
          panels = [
            (panel 6 "CPU" "%" (cpuBy "comm") "{{comm}}")
            (panel 6 "RSS" "MiB" (rssBy "comm") "{{comm}}")
          ];
        }
        {
          title = "systemd";
          panels = [
            (panel 12 "Failed units" "" ''node_systemd_unit_state{${s},state="failed"} == 1'' "{{name}}")
          ];
        }
      ];
    };

  dashboards = pkgs.linkFarm "vmui-dashboards" (
    [{ name = "00-overview.json"; path = pkgs.writeText "overview.json" (builtins.toJSON overview); }]
    ++ map
      (host: {
        name = "host-${host}.json";
        path = pkgs.writeText "host-${host}.json" (builtins.toJSON (hostDashboard host));
      })
      cfg.hosts
  );
in
{
  config = lib.mkIf cfg.role.hub {
    services.victoriametrics.extraOptions = [ "-vmui.customDashboardsPath=${dashboards}" ];
  };
}
