{ pkgs, ... }: {
  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
  };
  # https://flox.dev/popular-packages/auto-environment-activation-with-direnv-flox/
  # https://raw.githubusercontent.com/flox/flox-direnv/v1.1.0/direnv.rc
  home.file.".config/direnv/lib/flox-direnv.sh".source = ./flox-direnv_v1.1.0.rc;
}
