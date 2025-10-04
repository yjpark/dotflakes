{
  plugins.nvim-tree.enable = true;
  keymaps = [
    {
      action = "<cmd>NvimTreeFindFileToggle<CR>";
      key = ",b";
    }
    {
      action = "<cmd>NvimTreeFindFile<CR>";
      key = ",e";
    }
  ];
}
