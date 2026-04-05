{
  programs.nixvim = {
    clipboard.providers.wl-copy.enable = false;
    extraConfigLuaPost = ''
      local osc52 = require('vim.ui.clipboard.osc52')
      vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
          ['+'] = osc52.copy('+'),
          ['*'] = osc52.copy('*'),
        },
        paste = {
          -- OSC 52 paste queries the terminal and hangs if unsupported.
          -- Returning nil lets neovim use its built-in paste handling.
          ['+'] = function() return nil end,
          ['*'] = function() return nil end,
        },
      }
    '';
  };
}
