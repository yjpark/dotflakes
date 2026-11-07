{
  flake,
  pkgs,
  ...
}:
let
    kimi-code = flake.inputs.kimi-code.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # claude-code itself is installed by programs.claude-code (as a wrapper once
  # mcpServers is set), so it is not listed again here.
  home.packages = [
    kimi-code.default
  ];
}
