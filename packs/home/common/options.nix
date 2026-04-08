# User configuration module
{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    me = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Your username as shown by `id -un`";
      };
      fullname = lib.mkOption {
        type = lib.types.str;
        description = "Your full name for use in Git config";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Your email for use in Git config";
      };
      niri.extraConfig = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Extra niri KDL config appended to config.common.kdl";
      };
    };
  };
  config = {
    home.username = config.me.username;
    home.homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "/Users/${config.me.username}"
      else "/home/${config.me.username}";
  };
}
