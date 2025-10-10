{ config, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        email = config.me.email;
        name = config.me.fullname;
      };
    };
  };
  programs.jjui = {
    enable = true;
  };
}
