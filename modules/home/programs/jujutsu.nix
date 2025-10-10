{ config, ... }: {
  programs.jujutsu.enable = true;
  programs.jjui = {
    enable = true;
    settings = {
      email = config.me.email;
      name = config.me.fullname;
    };
  };
}
