{
  config,
  pkgs,
  ...
}: {
  programs.jujutsu = {
    enable = true;
    settings = {
      ui.default-command = ["log" "--no-pager" "--limit" "20"];
      user = {
        email = config.me.email;
        name = config.me.fullname;
      };
      git = {
        push = "yjpark";
        fetch = ["origin" "yjpark"];
      };
    };
  };
  programs.jjui = {
    enable = true;
  };
  home.packages = with pkgs; [
    lazyjj
  ];
}
