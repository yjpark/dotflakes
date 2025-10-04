{
  plugins.telescope = {
    enable = true;
    keymaps = {
      ",p" = {
        options.desc = "file finder";
        action = "find_files";
      };
      ",r" = {
        options.desc = "recent files";
        action = "oldfiles";
      };
      ",." = {
        options.desc = "find via grep";
        action = "live_grep";
      };
      "<leader>T" = {
        options.desc = "switch colorscheme";
        action = "colorscheme";
      };
    };
    extensions = {
      file-browser.enable = true;
      ui-select.enable = true;
      frecency.enable = true;
      fzf-native.enable = true;
    };
  };
}
