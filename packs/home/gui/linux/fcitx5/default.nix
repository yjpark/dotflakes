{pkgs, ...}: {
  i18n.inputMethod.fcitx5 = {
    addons = with pkgs; [
      fcitx5-chinese-addons
    ];

    settings = {
      inputMethod = {
        "Groups/0" = {
          Name = "Default";
          "Default Layout" = "us";
          DefaultIM = "shuangpin";
        };
        "Groups/0/Items/0" = {
          Name = "keyboard-dvorak";
          Layout = "";
        };
        "Groups/0/Items/1" = {
          Name = "shuangpin";
          Layout = "";
        };
        GroupOrder."0" = "Default";
      };

      addons.pinyin.globalSection = {
        ShuangPinProfile = "MS";
        Shuangpin = "True";
      };
    };
  };
}
