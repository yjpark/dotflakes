{ config, pkgs, ... }:
let
  ports = {
    pc = 22022;
    edger = 22023;
  };
  port = ports.${config.networking.hostName};
in
{
  programs.ssh.knownHosts."hub.yjpark.org".publicKey =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMvzj3BZ1UggfjzJdt0dj10d4nH8o4w4pdQlQpniqtZ+";

  systemd.services.ssh-reverse-hub = {
    description = "Reverse SSH tunnel to hub.yjpark.org";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment.AUTOSSH_GATETIME = "0";
    startLimitIntervalSec = 0;
    serviceConfig = {
      ExecStart = "${pkgs.autossh}/bin/autossh -M 0 -N -i /etc/ssh/ssh_host_ed25519_key -R 127.0.0.1:${toString port}:127.0.0.1:22 -o ExitOnForwardFailure=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o StrictHostKeyChecking=yes tunnel@hub.yjpark.org";
      Restart = "always";
      RestartSec = 10;
    };
  };
}
