{ pkgs, ... }: {
  programs = {
    bat.enable = true;
    bottom.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    eza.enable = true;
    jq.enable = true;
    password-store.enable = true;
  };
}
