# The hub for this host's kudo nodes, on the incus bridge.
#
# Bound to the bridge address so the host's own kudo-node and its containers'
# nodes reach it, and nothing on the LAN does. One hub per host for now; hubs on
# different hosts are not linked yet.
{ flake, ... }: {
  imports = [ flake.inputs.hub.nixosModules.hub ];

  services.hub = {
    enable = true;
    address = "10.100.0.1:15400";
  };

  # Containers reach the host only through the incus zone; open the hub there.
  services.firewalld.zones.incus.ports = [
    { port = 15400; protocol = "tcp"; }
  ];

  # The host's kudo-node is a user service and must start without a login.
  users.users.yjpark.linger = true;
}
