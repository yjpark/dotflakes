{pkgs, ...}: {
  programs = {
    bat.enable = true;
    bottom.enable = true;
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    eza.enable = true;
    jq.enable = true;
    password-store = {
      enable = true;
      settings = { PASSWORD_STORE_DIR = "$XDG_DATA_HOME/password-store"; };
    };
  };
}
