{ ... }: {
  me.monitoringHub = "edger.yjpark.zerotier";
  me.niri.extraConfig = builtins.readFile ./niri.extras.kdl;
}
