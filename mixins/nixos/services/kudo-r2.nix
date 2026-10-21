# The kudo context store's R2 key, handed to this host's yolo container.
#
# yolo has no age key, so it cannot read sops files: the host decrypts the key
# into an env file and pushes it into the container after every switch (and
# whenever the container starts again), owned by the container's yj, mode 0400.
# kudo-node there reads it as an EnvironmentFile; the key never travels on a
# command line nor through the hub. Secret: secrets/kudo-r2.yaml.
{ config, pkgs, ... }:
let
  key = name: {
    sopsFile = ./secrets/kudo-r2.yaml;
    key = name;
  };
  env = config.sops.templates."kudo-r2.env".path;
  incus = "${config.virtualisation.incus.package}/bin/incus";
in
{
  sops.secrets."kudo-r2/aws_access_key_id" = key "aws_access_key_id";
  sops.secrets."kudo-r2/aws_secret_access_key" = key "aws_secret_access_key";
  sops.secrets."kudo-r2/aws_endpoint" = key "aws_endpoint";
  sops.templates."kudo-r2.env".content = ''
    AWS_ACCESS_KEY_ID=${config.sops.placeholder."kudo-r2/aws_access_key_id"}
    AWS_SECRET_ACCESS_KEY=${config.sops.placeholder."kudo-r2/aws_secret_access_key"}
    AWS_ENDPOINT=${config.sops.placeholder."kudo-r2/aws_endpoint"}
  '';

  systemd.services.kudo-r2-push = {
    description = "Push the kudo R2 key into the yolo container";
    after = [ "incus.service" "sops-install-secrets.service" ];
    wants = [ "incus.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ config.sops.templates."kudo-r2.env".content ];
    # A container still booting is retried.
    startLimitIntervalSec = 0;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      # No yolo on this host: nothing to do.
      ${incus} info yolo >/dev/null 2>&1 || exit 0
      ${incus} exec yolo -- mkdir -p /home/yj/.config/kudo
      ${incus} exec yolo -- chown 1000:100 /home/yj/.config/kudo
      ${incus} file push --uid 1000 --gid 100 --mode 0400 ${env} yolo/home/yj/.config/kudo/r2.env
      # Pick it up: restarting the node leaves its jobs running.
      ${incus} exec yolo -- ${pkgs.util-linux}/bin/runuser -u yj -- \
        env XDG_RUNTIME_DIR=/run/user/1000 systemctl --user try-restart kudo-node.service kudo-console.service || true
    '';
  };
}
