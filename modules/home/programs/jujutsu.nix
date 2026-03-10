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
      ui.default-command = [
        "log"
        "--no-pager"
        "--limit"
        "20"
      ];
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
        local-heads = [ "log" "--stat" "-r" "visible_heads() ~ remote_bookmarks()"];
        dt = ["diff" "--tool" "difftastic"];
      };

      merge-tools.difftastic = {
        program = "difft";
        diff-args = ["--color=always" "$left" "$right"];
      };
    };
  };
  programs.jjui = {
    enable = true;
    package = flake.inputs.jjui.packages.${pkgs.stdenv.hostPlatform.system}.jjui;
  };
  home.packages = with pkgs; [
    lazyjj
  ];
}
