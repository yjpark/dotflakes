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
          ['+'] = osc52.paste('+'),
          ['*'] = osc52.paste('*'),
        },
      }
    '';
  };
}
