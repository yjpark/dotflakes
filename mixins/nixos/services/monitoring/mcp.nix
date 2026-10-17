{ config, lib, pkgs, ... }:
# MCP servers for agents, one pair per hub, in Streamable HTTP mode:
#
#   http://<hub>.yjpark.zerotier:8430/mcp   VictoriaMetrics (metrics, PromQL/MetricsQL)
#   http://<hub>.yjpark.zerotier:9430/mcp   VictoriaLogs (journald, LogsQL)
#
# Served from the hubs rather than launched per client, so any agent that can
# reach a hub (hosts, incus containers, other machines on ZeroTier) only needs
# the URL. Every hub holds the full dataset, so either hub answers for all hosts.
#
# Same exposure as the hub UIs (see hub.nix): ZeroTier and the local site only.
let
  cfg = config.monitoring;
  hubAddr = cfg.hubs.${config.networking.hostName};

  # Upstream pins go 1.26.2; relax to major.minor like nixpkgs' victorialogs so
  # the nixpkgs Go toolchain builds it.
  mcpServer = { pname, version, hash }: pkgs.buildGoModule {
    inherit pname version;
    src = pkgs.fetchFromGitHub {
      owner = "VictoriaMetrics";
      repo = pname;
      tag = "v${version}";
      inherit hash;
    };
    vendorHash = null;
    subPackages = [ "cmd/${pname}" ];
    postPatch = ''
      sed -i -E 's/^(go[[:space:]]+[[:digit:]]+\.[[:digit:]]+)\.[[:digit:]]+$/\1/' go.mod
      sed -i -E 's/^(## explicit; go[[:space:]]+[[:digit:]]+\.[[:digit:]]+)\.[[:digit:]]+$/\1/' vendor/modules.txt
    '';
    env.CGO_ENABLED = 0;
    doCheck = false;
    meta.mainProgram = pname;
  };

  mcp-victoriametrics = mcpServer {
    pname = "mcp-victoriametrics";
    version = "1.20.2";
    hash = "sha256-7kN7qwsvTL0scfBxMO/nrvikiysUxPY8nSFkhJsgGDM=";
  };

  mcp-victorialogs = mcpServer {
    pname = "mcp-victorialogs";
    version = "1.9.0";
    hash = "sha256-esfd6Eg1j2BCgee1T5tiIdSPWVEBqhI4UGDKRFYyn3s=";
  };

  service = { description, package, port, environment }: {
    inherit description;
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      MCP_SERVER_MODE = "http";
      MCP_LISTEN_ADDR = ":${toString port}";
    } // environment;
    serviceConfig = {
      ExecStart = lib.getExe package;
      DynamicUser = true;
      Restart = "on-failure";
    };
  };
in
{
  options.monitoring.ports = {
    mcpVictoriametrics = lib.mkOption {
      type = lib.types.port;
      default = 8430;
    };
    mcpVictorialogs = lib.mkOption {
      type = lib.types.port;
      default = 9430;
    };
  };

  config = lib.mkIf cfg.role.hub {
    systemd.services.mcp-victoriametrics = service {
      description = "MCP server for VictoriaMetrics";
      package = mcp-victoriametrics;
      port = cfg.ports.mcpVictoriametrics;
      environment = {
        VM_INSTANCE_ENTRYPOINT = "http://127.0.0.1:${toString cfg.ports.victoriametrics}";
        VM_INSTANCE_TYPE = "single";
      };
    };

    systemd.services.mcp-victorialogs = service {
      description = "MCP server for VictoriaLogs";
      package = mcp-victorialogs;
      port = cfg.ports.mcpVictorialogs;
      environment = {
        VL_INSTANCE_ENTRYPOINT = "http://127.0.0.1:${toString cfg.ports.victorialogs}";
      };
    };

    # Listed on the host hub page as copyable URLs: agents need the URL, there
    # is nothing to browse.
    ingress.services = {
      mcp-vm = {
        title = "VictoriaMetrics MCP";
        group = "Monitoring";
        url = "http://${hubAddr}:${toString cfg.ports.mcpVictoriametrics}/mcp";
      };
      mcp-logs = {
        title = "VictoriaLogs MCP";
        group = "Monitoring";
        url = "http://${hubAddr}:${toString cfg.ports.mcpVictorialogs}/mcp";
      };
    };
  };
}
