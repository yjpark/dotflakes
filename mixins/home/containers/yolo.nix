{ flake, ... }:
let
  mirror = "s3://kudo-contexts/contexts";
  r2Env = "-%h/.config/kudo/r2.env";
in
{
  imports = [ (flake.inputs.self + /mixins/home/settings/kudo-node.nix) ];

  # yolo is sandboxed (outbound traffic goes through OneCLI): its kudo
  # workers run their agent CLI bypassing permissions. Only here.
  services.kudo-node.environment.KUDO_WORKER_BYPASS = "1";

  # The context store's mirror, shared by every host's yolo: the bucket and
  # region here, the key in ~/.config/kudo/r2.env (pushed by the host,
  # mixins/nixos/services/kudo-r2.nix; absent until then, and the store stays
  # local).
  services.kudo-node.environment.KUDO_CONTEXT_MIRROR = mirror;
  services.kudo-node.environment.AWS_REGION = "auto";
  systemd.user.services.kudo-node.Service.EnvironmentFile = [ r2Env ];

  # The kudo console, reached at https://yolo-8080.pc.yjpark.org through the
  # ingress. It runs the release build in the kudo checkout (run by hand until
  # its views settle): rebuild with
  #   dx build -p kudo-console --web --fullstack --release
  # then `systemctl --user restart kudo-console`. No login: it listens on
  # 127.0.0.1 only, and starts workers only on the yolos (pc's and edger's).
  systemd.user.services.kudo-console = let
    web = "%h/agents/edger/kudo/target/dx/kudo-console/release/web";
  in {
    Unit = {
      Description = "kudo console (the release build in the kudo checkout)";
      After = [ "kudo-node.service" ];
      # Only where the console is built (yolo's config is shared by every
      # host's yolo; the console runs on pc's).
      ConditionPathExists = "${web}/server";
    };
    Service = {
      WorkingDirectory = web;
      ExecStart = "${web}/server";
      Environment = [
        "PORT=8080"
        "KUDO_HUB_ADDR=10.100.0.1:15400"
        "KUDO_CONSOLE_WORKER_NODES=yolo,edger::yolo"
        "KUDO_CONSOLE_HOSTS=8080.yolo.incus"
        "KUDO_CONSOLE_ORIGINS=https://yolo-8080.pc.yjpark.org"
        "KUDO_CONTEXT_MIRROR=${mirror}"
        "AWS_REGION=auto"
      ];
      EnvironmentFile = [ r2Env ];
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
