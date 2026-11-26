{ pkgs, ... }:

let
  agent = pkgs.stdenv.mkDerivation {
    pname = "cloudmonitor-agent";
    version = "4.0.0";

    src = pkgs.fetchurl {
      url = "https://cms-agent-cn-shanghai.oss-cn-shanghai.aliyuncs.com/Argus/4.0.0/cloudmonitor_linux64.tar.gz";
      sha256 = "f3012ffa6d9b68c857a792a714ea2e1af97dc786e5ea3767f3003cd009400c71";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    sourceRoot = "cloudmonitor";
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      mkdir -p $out
      cp -a . $out/
    '';
  };
in
{
  systemd.services.cloudmonitor = {
    description = "Alibaba CloudMonitor agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [
      pkgs.coreutils
      pkgs.gawk
      pkgs.gnugrep
      pkgs.procps
      pkgs.util-linux
    ];

    preStart = ''
      if [ -L /usr/local/cloudmonitor ]; then
        rm /usr/local/cloudmonitor
      fi
      install -d -m 0755 \
        /usr/local/cloudmonitor/bin \
        /usr/local/cloudmonitor/module \
        /usr/local/cloudmonitor/local_data/conf \
        /usr/local/cloudmonitor/local_data/logs
      cp -a ${agent}/bin/. /usr/local/cloudmonitor/bin/
      cp -a ${agent}/VERSION ${agent}/cloudmonitorCtl.sh ${agent}/cloudmonitor.service.usr \
        ${agent}/cloudmonitor.usr /usr/local/cloudmonitor/
      cp -an ${agent}/local_data/conf/. /usr/local/cloudmonitor/local_data/conf/
      touch /usr/local/cloudmonitor/agent.status
      chmod -R u+w /usr/local/cloudmonitor
    '';

    serviceConfig = {
      Type = "forking";
      KillMode = "mixed";
      PIDFile = "/run/argusagentd-cloudmonitor.pid";
      ExecStart = "/usr/local/cloudmonitor/cloudmonitorCtl.sh start-directly";
      ExecStop = "/usr/local/cloudmonitor/cloudmonitorCtl.sh stop-directly";
      TimeoutSec = 60;
      Restart = "on-failure";
      RestartSec = "60s";
    };
  };
}
