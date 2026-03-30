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
          -- Return empty content; use terminal paste (Ctrl+Shift+V) instead.
          ['+'] = function() return {""} end,
          ['*'] = function() return {""} end,
        },
      }
    '';
  };
}
