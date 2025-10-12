{ config, pkgs, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = config.me.email;
        name = config.me.fullname;
      };
      ui.default-command = [ "log" "--reversed" "--no-pager" "--limit" "20"];
    };
  };
  programs.jjui = {
    enable = true;
  };
  home.packages = with pkgs; [
    lazyjj
  ];
}
