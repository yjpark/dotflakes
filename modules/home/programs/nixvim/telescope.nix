{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<A-p>" = {
        options.desc = "file finder";
        action = "find_files";
      };
      "<C-z>" = {
        options.desc = "recent files";
        action = "oldfiles";
      };
      "<A-.>" = {
        options.desc = "find via grep";
        action = "grep_string";
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
  keymaps = [
    {
      action = "<cmd>Telescope<CR>";
      key = "<C-r>";
    }
  ];
}
