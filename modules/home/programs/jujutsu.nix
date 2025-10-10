{ config, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      email = config.me.email;
      name = config.me.fullname;
    };
  };
  programs.jjui = {
    enable = true;
  };
}
