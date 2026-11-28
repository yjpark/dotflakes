{ config, flake, ... }: {
  imports = [ (flake.inputs.self + /mixins/home/settings/kudo-node.nix) ];

  services.kudo-node.environment.KUDO_INTAKE_TARGETS =
    "kudo=${config.home.homeDirectory}/intake/kudo";

  me.monitoringHub = "edger.yjpark.zerotier";
  me.niri.extraConfig = builtins.readFile ./niri.extras.kdl;
}
