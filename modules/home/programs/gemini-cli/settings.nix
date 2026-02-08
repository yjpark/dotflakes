{pkgs, ...}: {
  programs.gemini-cli = {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.gemini-cli.enable
    enable = true;
  };
}
