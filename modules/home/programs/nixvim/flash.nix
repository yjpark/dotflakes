{
  plugins.flash = {
    enable = true;
  };
  keymaps = [
    {
      key = "s";
      mode = ["n" "x" "o"];
      action.__raw = ''
        function()
          require('flash').jump()
        end
      '';
      options.desc = "Remote Flash";
      options.remap = true;
    }
    {
      key = "S";
      mode = ["n" "x" "o"];
      action.__raw = ''
        function()
          require('flash').treesitter()
        end
      '';
      options.desc = "Remote Flash Treesitter";
      options.remap = true;
    }
    {
      key = "r";
      mode = "o";
      action.__raw = ''
        function()
          require('flash').remote()
        end
      '';
      options.desc = "Remote Flash";
      options.remap = true;
    }
    {
      key = "R";
      mode = ["x" "o"];
      action.__raw = ''
        function()
          require('flash').treesitter_search()
        end
      '';
      options.desc = "Flash Treesitter Search";
      options.remap = true;
    }
    {
      key = "<leader>s";
      mode = "c";
      action.__raw = ''
        function()
          require('flash').toggle()
        end
      '';
      options.desc = "Toggle Flash Search";
      options.remap = true;
    }
  ];
}
