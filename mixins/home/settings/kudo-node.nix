# kudo-node as a user service, dialing this host's hub on the incus bridge.
# Used by the incus hosts (pc, edger) and their yolo containers.
{ flake, ... }: {
  imports = [ flake.inputs.kudo.homeModules.kudo-node ];

  services.kudo-node = {
    enable = true;
    hubAddr = "10.100.0.1:15400";
  };
}
