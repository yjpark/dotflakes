{pkgs, ...}: {
  programs.television = {
    enable = true;
    enableFishIntegration = false; # NOT using the shell_integration keybindings, so manually import it in fish
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

  xdg.configFile."television/cable/cliphist.toml".text = ''
    [metadata]
    name = "cliphist"
    description = "Clipboard history (via cliphist)"

    [source]
    command = "cliphist list"

    [preview]
    command = "cliphist decode <<< '{}'"
  '';

  home.packages = [
    (pkgs.writeShellScriptBin "update-television-fish-completion"  ''
      #!/usr/bin/env bash
      tv init fish > ~/.flakes/modules/home/programs/fish/completions/television-completion.fish
    '')
  ];
}
