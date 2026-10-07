{ config, lib, ... }:
# Monitoring topology, written once. Every always-on host imports this mixin;
# the hub and agent modules derive their config from the data here rather than
# repeating hub addresses per host.
#
# Topology: one hub per site, replicated. Each agent writes to *all* hubs, so
# every hub holds the full dataset and a site keeps working on its own while the
# ZeroTier link is down (agents queue per remote URL on disk and replay later).
#
# Hubs are addressed by their <host>.yjpark.zerotier names, which resolve and
# route from every site (packs/nixos/host/zerotier). ZeroTier is in the
# firewalld trusted zone, so nothing here opens ports in other zones.
let
  cfg = config.monitoring;
in
{
  imports = [ ./hub.nix ./agent.nix ];

  options.monitoring = {
    hubs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        pc = "pc.yjpark.zerotier";
        edger = "edger.yjpark.zerotier";
      };
      description = "Hub host name mapped to the address agents write to.";
    };

    role = {
      hub = lib.mkOption {
        type = lib.types.bool;
        default = cfg.hubs ? ${config.networking.hostName};
        defaultText = lib.literalExpression "monitoring.hubs ? networking.hostName";
        description = "Run VictoriaMetrics + VictoriaLogs storage and UI on this host.";
      };

      agent = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Ship this host's metrics and journald logs to all hubs.";
      };
    };

    ports = {
      victoriametrics = lib.mkOption {
        type = lib.types.port;
        default = 8428;
      };
      victorialogs = lib.mkOption {
        type = lib.types.port;
        default = 9428;
      };
      nodeExporter = lib.mkOption {
        type = lib.types.port;
        default = 9100;
        description = "node_exporter, bound to localhost.";
      };
      vmagent = lib.mkOption {
        type = lib.types.port;
        default = 8429;
        description = "vmagent HTTP (self-metrics), bound to localhost.";
      };
      vlagent = lib.mkOption {
        type = lib.types.port;
        default = 9429;
        description = "vlagent journald ingest, bound to localhost.";
      };
    };

    labels = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      readOnly = true;
      description = "Labels attached to everything this host ships.";
    };

    vmWriteUrls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      description = "VictoriaMetrics remote-write URL of every hub.";
    };

    vlWriteUrls = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      readOnly = true;
      description = "VictoriaLogs /internal/insert URL of every hub, for vlagent.";
    };
  };

  config.monitoring = {
    labels = {
      host = config.networking.hostName;
    } // lib.optionalAttrs (lib.hasAttrByPath [ "site" "id" ] config) {
      site = config.site.id;
    };

    vmWriteUrls = lib.mapAttrsToList
      (_: addr: "http://${addr}:${toString cfg.ports.victoriametrics}/api/v1/write")
      cfg.hubs;

    vlWriteUrls = lib.mapAttrsToList
      (_: addr: "http://${addr}:${toString cfg.ports.victorialogs}/internal/insert")
      cfg.hubs;
  };
}
