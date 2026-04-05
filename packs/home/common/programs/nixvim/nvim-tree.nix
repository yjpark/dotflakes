{
  plugins.nvim-tree.enable = true;
  keymaps = [
    {
      action = "<cmd>NvimTreeFindFileToggle<CR>";
      key = ",b";
    }
    {
      action = "<cmd>NvimTreeFindFile<CR>";
      key = "<A-e>";
    }
  ];
  autoCmd = [
    {
      event = ["FileType"];
      pattern = ["NvimTree"];
      callback = {
        __raw = ''
          function()
            -- vim.schedule defers the mapping by one tick, ensuring it runs
            -- AFTER all other plugins (like Noice) have finished their buffer setups.
            vim.schedule(function()
              vim.keymap.set('n', '?', require('nvim-tree.api').tree.toggle_help, {
                buffer = true,
                noremap = true,
                nowait = true,
                desc = "Toggle NvimTree Help"
              })
            end)
          end
        '';
      };
    }
  ];
}
