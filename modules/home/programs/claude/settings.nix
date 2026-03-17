{
  ...
}: {
  programs.claude-code = {
    enable = true;
    settings = {
      statusLine = {
        type = "command";
        # command = "uv run ~/.claude/scripts/statusline.py";
        command = "ccline";
      };
      enabledPlugins = {
        "skill-creator@claude-plugins-official" = true;
      };
    };
  };

  home.file.".claude/justfile".source = ./files/claude.justfile;
}
