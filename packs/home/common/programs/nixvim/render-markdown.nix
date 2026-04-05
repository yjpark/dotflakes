{
  plugins.render-markdown = {
    enable = true;
  };
  keymaps = [
    {
      mode = "n";
      key = "<M-u>"; # <M-> stands for Meta/Alt in Neovim
      action = "<cmd>RenderMarkdown toggle<CR>";
      options = {
        desc = "Toggle Markdown Render Mode";
        silent = true;
      };
    }
  ];
}
