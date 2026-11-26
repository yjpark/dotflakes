# The hub for this host's kudo nodes, on the incus bridge — peered with the
# other private hub over ZeroTier and the public hub over authenticated WSS.
#
# Bound to the bridge address so the host's own kudo-node and its containers'
# nodes reach it, and to the host's ZeroTier address so the other hosts' hubs
# do (ZeroTier sources sit in firewalld's trusted zone); nothing on the LAN
# does. A peer's nodes appear here as `<host>::<node>` (`edger::yolo`), one hop
# away.
{ flake, config, lib, pkgs, ... }:
let
  # The hosts running a private hub, by ZeroTier address.
  hubs = {
    pc = "172.22.1.9";
    edger = "172.22.1.2";
  };
  me = config.networking.hostName;
  hubSecret = {
    sopsFile = ../../../nixos/hosts/hub.yjpark.org/secrets/hub.env.txt;
    format = "dotenv";
    key = "";
  };
  incus = "${config.virtualisation.incus.package}/bin/incus";
in
{
  imports = [ flake.inputs.hub.nixosModules.hub ];

  services.hub = {
    enable = true;
    address = "10.100.0.1:15400";
    extraAddresses = lib.optional (hubs ? ${me}) "${hubs.${me}}:15400";
    environmentFile = config.sops.secrets."hub.env".path;
    name = me;
    peers = lib.mapAttrs (_: ip: "${ip}:15400") (removeAttrs hubs [ me ]) // {
      hub = "ws://127.0.0.1:15401";
    };
  };

  sops.secrets."hub.env" = hubSecret;
  sops.secrets."kudo-hub-user.env" = hubSecret // {
    owner = "yjpark";
  };

  # Containers reach the host only through the incus zone; open the hub there.
  services.firewalld.zones.incus.ports = [
    { port = 15400; protocol = "tcp"; }
  ];

  # The host's kudo-node is a user service and must start without a login.
  users.users.yjpark.linger = true;

  systemd.services.kudo-hub-auth-push = {
    description = "Push hub authentication into the yolo container";
    after = [ "incus.service" "sops-install-secrets.service" ];
    wants = [ "incus.service" ];
    wantedBy = [ "multi-user.target" ];
    restartTriggers = [ "${hubSecret.sopsFile}" ];
    startLimitIntervalSec = 0;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 10;
    };
    script = ''
      ${incus} info yolo >/dev/null 2>&1 || exit 0
      ${incus} exec yolo -- mkdir -p /home/yj/.config/kudo
      ${incus} exec yolo -- chown 1000:100 /home/yj/.config/kudo
      ${incus} file push --uid 1000 --gid 100 --mode 0400 \
        ${config.sops.secrets."hub.env".path} yolo/home/yj/.config/kudo/hub.env
      ${incus} exec yolo -- ${pkgs.util-linux}/bin/runuser -u yj -- \
        env XDG_RUNTIME_DIR=/run/user/1000 systemctl --user try-restart \
        kudo-node.service kudo-console.service kudo-waker.service || true
    '';
  };
}
