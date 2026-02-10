{
  flake,
  ...
}: {
  home.packages = with flake.inputs.llm-agents.packages.${system}; [
    claude-code
    openspec
    agent-browser
    opencode
    claudebox
    skills-installer
    ccusage
  ];
}
