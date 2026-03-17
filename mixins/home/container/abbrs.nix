{
  programs.fish.shellAbbrs = {
    c = "claude --permission-mode bypassPermissions";
    cs = "claude --permission-mode bypassPermissions --model sonnet";
    co = "claude --permission-mode bypassPermissions --model opus";
    ch = "claude --permission-mode bypassPermissions --model haiku";
  };
}
