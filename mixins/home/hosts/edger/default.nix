{ flake, ... }: {
  imports = [ (flake.inputs.self + /mixins/home/settings/kudo-node.nix) ];

  me.monitoringHub = "edger.yjpark.zerotier";
  me.niri.extraConfig = builtins.readFile ./niri.extras.kdl;
}
