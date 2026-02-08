{pkgs, ...}: {
  programs.claude-code = {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.claude-code.enable
    enable = true;
  };
}
