{
  programs.nixvim = {
    clipboard.providers.wl-copy.enable = true;
    extraLuaConfig = ''
      -- Use OSC 52 for clipboard so it works inside Zellij/tmux
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
