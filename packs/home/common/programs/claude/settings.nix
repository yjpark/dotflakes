{
  ...
}: {
  home.sessionVariables = {
    CLAUDE_CODE_NEW_INIT = "1";
    CLAUDE_CODE_NO_FLICKER = "1";
    #CLAUDE_CODE_DISABLE_ALTERNATE_SCREEN = "1";
  };

  programs.claude-code = {
    enable = true;
  };
}
