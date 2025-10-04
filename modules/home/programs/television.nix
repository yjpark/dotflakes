{
  programs.television = {
    enable = true;
    settings = {
      keybindings = {
        ctrl-r = "toggle_remote_control";
      };
      shell_integration.keybindings = {
        smart_autocomplete = "ctrl-r";
        command_history = "ctrl-h";
      };
    };
  };
  programs.nix-search-tv.enable = true;
}
