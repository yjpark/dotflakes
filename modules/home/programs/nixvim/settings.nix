{
  opts = {
    expandtab = true;
    shiftwidth = 2;
    smartindent = true;
    tabstop = 2;
    number = true;
    clipboard = "unnamedplus";
    termguicolors = true;
    background = "dark";
    cursorline = true;
    cursorcolumn = false;
  };
  clipboard.providers.wl-copy.enable = true;
  autoCmd = [
      {
          command = "setlocal cursorcolumn";
          event = [ "InsertEnter" ];
          pattern = [ "*" ];
      }
      {
          command = "setlocal nocursorcolumn";
          event = [ "InsertLeave" ];
          pattern = [ "*" ];
      }
  ];
}
