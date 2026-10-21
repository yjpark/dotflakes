# The hub for this host's kudo nodes, on the incus bridge — and peered with
# the other hosts' hubs over ZeroTier.
#
# Bound to the bridge address so the host's own kudo-node and its containers'
# nodes reach it, and to the host's ZeroTier address so the other hosts' hubs
# do (ZeroTier sources sit in firewalld's trusted zone); nothing on the LAN
# does. A peer's nodes appear here as `<host>::<node>` (`edger::yolo`), one hop
# away.
{ flake, config, lib, ... }:
let
  # The hosts running a hub, by ZeroTier address (see packs/nixos/host/zerotier).
  hubs = {
    pc = "172.22.1.9";
    edger = "172.22.1.2";
  };
  me = config.networking.hostName;
in
{
  imports = [ flake.inputs.hub.nixosModules.hub ];

  services.hub = {
    enable = true;
    address = "10.100.0.1:15400";
    extraAddresses = lib.optional (hubs ? ${me}) "${hubs.${me}}:15400";
    name = me;
    peers = lib.mapAttrs (_: ip: "${ip}:15400") (removeAttrs hubs [ me ]);
  };

  # Containers reach the host only through the incus zone; open the hub there.
  services.firewalld.zones.incus.ports = [
    { port = 15400; protocol = "tcp"; }
  ];

  # The host's kudo-node is a user service and must start without a login.
  users.users.yjpark.linger = true;
}
