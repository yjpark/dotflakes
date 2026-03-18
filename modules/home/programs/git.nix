{
  config,
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    settings.user.name = config.me.fullname;
    settings.user.email = config.me.email;
    settings = {
      init.defaultBranch = "main";
      # url."git@github.com:".insteadOf = "https://github.com/";
      remote.pushDefault = config.me.username;
      push.default = "current";
      pull.rebase = "false";
      diff.tool = "difftastic";
      pager.difftoo = true;
      difftool.prompt = false;
      difftool."difftastic".cmd = ''difft "$MERGED" "$LOCAL" "abcdef1" "100644" "$REMOTE" "abcdef2" "100644"'';
    };
    settings.alias = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      dt = "difftool";
      mt = "mergetool";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      rg = "reflog --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      t = "worktree";
      tl = "worktree list";
    };
    lfs.enable = true;
  };
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
  programs.gh = {
    enable = true;
    extensions = [
      pkgs.gh-dash
    ];
  };
  programs.lazygit = {
    enable = true;
  };
  home.packages= [ pkgs.gitu ];
}
