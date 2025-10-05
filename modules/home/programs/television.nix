{
  programs.television = {
    enable = true;
    settings = {
      keybindings = {
        ctrl-r = "toggle_remote_control";
        ctrl-t = "quit";
      };
      shell_integration.keybindings = {
        smart_autocomplete = "ctrl-r";
        command_history = "ctrl-z";
      };
    };
  };
  programs.nix-search-tv.enable = true;
}
