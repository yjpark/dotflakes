{
  flake,
  pkgs,
  ...
}:
{
  imports = [
    (flake.inputs.self + /mixins/home/host/common/ai.nix)
  ];
  programs.claude-code.package = flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

  home.packages = with flake.inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
    gemini-cli
  ];
}
