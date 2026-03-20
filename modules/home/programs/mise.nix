{...}: {
  programs.mise.enable = true;
  programs.fish.functions.tv-mise-tasks = ''
    set -l result (tv mise-tasks)
    and mise run $result
  '';

  programs.television.channels.mise-tasks = {
    metadata = {
      name = "mise-tasks";
      description = "A channel to select and run mise tasks";
      requirements = [ "mise" ];
    };
    source.command = "mise tasks ls --no-header | awk '{print $1}'";
    preview.command = "mise tasks info {}";
    keybindings.f5 = "actions:run-task";
    actions.run-task = {
      description = "Run a mise task";
      command = "mise run {}";
      mode = "execute";
    };
  };
}
