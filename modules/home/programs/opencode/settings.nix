{pkgs, ...}: {
  programs.opencode = {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.opencode.enable
    enable = true;
    web.enable = true;
  };
}
