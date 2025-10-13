{
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;
    #theme = "papercolor_dark";
    settings.keyboard.bindings = [
      {
        key = "T";
        mods = "Control";
        action = "CreateNewTab";
      }
      {
        key = "1";
        mods = "Control";
        action = "SelectTab1";
      }
      {
        key = "2";
        mods = "Control";
        action = "SelectTab2";
      }
      {
        key = "3";
        mods = "Control";
        action = "SelectTab3";
      }
      {
        key = "4";
        mods = "Control";
        action = "SelectTab4";
      }
      {
        key = "5";
        mods = "Control";
        action = "SelectTab5";
      }
      {
        key = "6";
        mods = "Control";
        action = "SelectTab6";
      }
      {
        key = "7";
        mods = "Control";
        action = "SelectTab7";
      }
      {
        key = "8";
        mods = "Control";
        action = "SelectTab8";
      }
      {
        key = "9";
        mods = "Control";
        action = "SelectTab9";
      }
    ];
  };
}
