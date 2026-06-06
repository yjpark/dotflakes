{
  programs.fish.shellAbbrs = {
    c = "claude --dangerously-skip-permissions";
    cs = "claude --dangerously-skip-permissions --model sonnet";
    co = "claude --dangerously-skip-permissions --model opus";
    ch = "claude --dangerously-skip-permissions --model haiku";
    cn = "claude --dangerously-skip-permissions --model opusplan";
    x = "codex --dangerously-bypass-approvals-and-sandbox";
  };
}
