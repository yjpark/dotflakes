{ config, pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = config.me.fullname;
    userEmail = config.me.email;
    extraConfig = {
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
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      dt = "difftool";
      mt = "mergetool";
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      rg = "reflog --color --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };
    lfs.enable = true;
    delta = {
      enable = true;
    };
  };
  home.packages = with pkgs; [
    difftastic
  ];
  programs.lazygit.enable = true;
}
