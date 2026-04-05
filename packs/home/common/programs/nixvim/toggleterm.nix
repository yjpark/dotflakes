{
  plugins.toggleterm = {
    enable = true;
    settings = {
      direction = "vertical";
      hide_numbers = true;
      shade_terminals = false;
      start_in_insert = true;

      # Wrapping this in __raw and [[ ]] completely bypasses Nixvim's string
      # escaping, preventing the "unclosed string" build error.
      open_mapping = {
        __raw = "[[<C-`>]]";
      };

      # We use __raw to pass the Lua function directly without it becoming a string
      size = {
        __raw = ''
          function(term)
            if term.direction == "horizontal" then
              return 15
            elseif term.direction == "vertical" then
              return vim.o.columns * 0.4
            end
          end
        '';
      };

      # The highlight links to fix the theme clash
      highlights = {
        Normal = {
          link = "Normal";
        };
        NormalFloat = {
          link = "NormalFloat";
        };
        FloatBorder = {
          link = "FloatBorder";
        };
      };
    };
  };
}
