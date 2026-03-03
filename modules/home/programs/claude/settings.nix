{
  flake,
  pkgs,
  ...
}: {
  programs.claude-code = {
    enable = true;
    package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
    settings = {
      statusLine = {
        type = "command";
        command = "uv run ~/.claude/scripts/statusline.py";
      };
      enabledPlugins = {
        "skill-creator@claude-plugins-official" = true;
      };
    };
  };

  home.file.".claude/justfile".source = ./files/claude.justfile;
}
