{
  flake,
  config,
  pkgs,
  ...
}:
{
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = "blt";
      user = {
        email = config.me.email;
        name = config.me.fullname;
      };
      git = {
        push = "yjpark";
        fetch = [
          "origin"
          "yjpark"
        ];
      };
      # https://github.com/jj-vcs/jj/blob/main/docs/config.md#set-of-immutable-commits
      revset-aliases = {
        "immutable_heads()" = "builtin_immutable_heads() | (trunk().. & ~mine())";
      };

      aliases = {
        try-resolve = [
          "util"
          "exec"
          "--"
          "sh"
          "-c"
          ''
            # 1. Let mergiraf try to solve it automatically first
            jj resolve --tool mergiraf "$@"

            # 2. Fallback to Neovim (jj-diffconflicts) for anything left over
            jj resolve --tool diffconflicts "$@"
          ''
          "" # (Required) This acts as $0 so any extra arguments map correctly
        ];
        bl = [
          "bookmark"
          "list"
        ];
        bla = [
          "bookmark"
          "list"
          "--all"
        ];
        blt = [
          "bookmark"
          "list"
          "--tracked"
        ];
      };

      merge-tools.diffconflicts = {
        program = "nvim";
        merge-args = [
          "-c"
          "let g:jj_diffconflicts_marker_length=$marker_length"
          "-c"
          "JJDiffConflicts!"
          "$output"
          "$base"
          "$left"
          "$right"
        ];
        # This tells jj that the plugin handles the markers natively
        merge-tool-edits-conflict-markers = true;
      };
    };
  };
  programs.jjui = {
    enable = true;
    package = flake.inputs.jjui.packages.${pkgs.stdenv.hostPlatform.system}.jjui;
  };
  programs.mergiraf = {
    enable = true;
    enableJujutsuIntegration = true;
    enableGitIntegration = true;
  };
  programs.difftastic = {
    enable = true;
    jujutsu.enable = true; # Injects the difftastic config into jj automatically
    options.display = "inline";
  };
}
