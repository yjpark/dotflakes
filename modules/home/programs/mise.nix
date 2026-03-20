{...}: {
  programs.mise.enable = true;
  programs.fish.functions._j_expand = ''
    set -l cmd (commandline -b)
    if test "$cmd" = "j"
        if test "$(mise config --json 2>/dev/null)" != "[]"
            commandline -r "mise run _"
            commandline -f complete complete
        else
            commandline -r "just "
        end
    else
        commandline -i " "
        commandline -f expand-abbr
    end
  '';

  programs.fish.interactiveShellInit = ''
    bind ' ' _j_expand
    bind -M insert ' ' _j_expand
  '';

  programs.fish.functions._jl_abbr = ''
    if test "$(mise config --json 2>/dev/null)" != "[]"
        echo "mise tasks"
    else
        echo "just -l"
    end
  '';

  programs.fish.functions.tv-mise-tasks = ''
    set -l task (tv mise-tasks)
    or return
    test -n "$task"
    or return
    set -l required_args (mise tasks info $task --json | jq '[.usage_spec.cmd.args[]] | length')
    if test "$required_args" -gt 0
      commandline -r "mise run $task "
    else
      mise run $task
    end
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
