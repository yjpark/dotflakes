{ flake, ... }: {
  imports = [ (flake.inputs.self + /mixins/home/settings/kudo-node.nix) ];

  # yolo is sandboxed (outbound traffic goes through OneCLI): its kudo
  # workers run their agent CLI bypassing permissions. Only here.
  services.kudo-node.environment.KUDO_WORKER_BYPASS = "1";
}
