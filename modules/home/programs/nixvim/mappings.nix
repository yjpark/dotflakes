{
  globals = {
    #mapleader = " ";
    direnv_auto = 1;
    direnv_silent_load = 0;
  };
  keymaps = [
    {
      action = ":";
      key = ";";
    }
    {
      action = ":bnext<CR>";
      key = "<C-n>";
    }
    {
      action = ":bprev<CR>";
      key = "<C-p>";
    }
    {
      action = "<C-o>0";
      key = "<C-a>";
      mode = "i";
    }
    {
      action = "<C-o>$";
      key = "<C-e>";
      mode = "i";
    }
    {
      action = "<C-o>X";
      key = "<C-h>";
      mode = "i";
    }
    {
      action = "0";
      key = "<C-a>";
      mode = "n";
    }
    {
      action = "$";
      key = "<C-e>";
      mode = "n";
    }
    {
      action = "X";
      key = "<C-h>";
      mode = "n";
    }
    {
      action = ":w<CR>";
      key = "<C-s>";
      mode = "n";
    }
    {
      action = "i";
      key = "<cr>";
      mode = "n";
    }
    {
      action = "i<bs>";
      key = "<bs>";
      mode = "n";
    }
    {
      action = "<Esc>:w<CR>";
      key = "<C-s>";
      mode = "i";
    }
    {
      action = ":bdelete<CR>";
      key = ",c";
      mode = "n";
    }
  ];
}
